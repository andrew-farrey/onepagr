"""
Post-processing step: inject /BBox into Figure structure elements.

Typst 0.15.1 tags meaningful images as /Figure structure elements (with alt
text) but does not emit a /BBox layout attribute on them -- confirmed via
direct testing (5 different Typst-side wrapping patterns, all identical: bare
image(), figure(), block()-in-figure(), box()-in-figure(), align()-wrapped).
Typst's own --pdf-standard ua-1 checker doesn't flag this as an error, but
PAC's stricter check does ("Figure element on a single page with no bounding
box"). Since no Typst-side markup fixes it, this computes the real bbox from
the page's own content stream (so it's correct regardless of how the
data-driven layout shifts a figure's position year to year) and writes it
directly into the compiled PDF's structure tree.

Requires: pip install pypdf

Usage: python add_figure_bbox.py input.pdf output.pdf
"""
import sys
from pypdf import PdfReader, PdfWriter
from pypdf.generic import (
    ContentStream, DictionaryObject, ArrayObject, IndirectObject,
    NumberObject, NameObject, FloatObject,
)


def mat_mult(a, b):
    a0, a1, a2, a3, a4, a5 = a
    b0, b1, b2, b3, b4, b5 = b
    return [
        a0 * b0 + a1 * b2, a0 * b1 + a1 * b3,
        a2 * b0 + a3 * b2, a2 * b1 + a3 * b3,
        a4 * b0 + a5 * b2 + b4, a4 * b1 + a5 * b3 + b5,
    ]


def extract_mcid_bboxes(reader, page_index):
    """For one page, return {mcid: [x0, y0, x1, y1]} covering every Do
    (XObject paint) operator executed while that MCID's marked-content
    section was open."""
    page = reader.pages[page_index]
    content = ContentStream(page.get_contents(), reader)

    stack = []
    ctm = [1, 0, 0, 1, 0, 0]
    mcid_stack = []  # supports nested BDC/EMC
    bboxes = {}

    for operands, operator in content.operations:
        op = operator.decode() if isinstance(operator, bytes) else operator
        if op == "q":
            stack.append(ctm[:])
        elif op == "Q":
            if stack:
                ctm = stack.pop()
        elif op == "cm":
            vals = [float(v) for v in operands]
            ctm = mat_mult(vals, ctm)
        elif op == "BDC":
            props = operands[1] if len(operands) > 1 else None
            mcid = None
            if isinstance(props, DictionaryObject) and "/MCID" in props:
                mcid = int(props["/MCID"])
            mcid_stack.append(mcid)
        elif op == "EMC":
            if mcid_stack:
                mcid_stack.pop()
        elif op == "Do":
            active_mcid = None
            for m in reversed(mcid_stack):
                if m is not None:
                    active_mcid = m
                    break
            if active_mcid is None:
                continue
            corners = [(0, 0), (1, 0), (0, 1), (1, 1)]
            xs, ys = [], []
            for x, y in corners:
                px = ctm[0] * x + ctm[2] * y + ctm[4]
                py = ctm[1] * x + ctm[3] * y + ctm[5]
                xs.append(px)
                ys.append(py)
            box = [min(xs), min(ys), max(xs), max(ys)]
            if active_mcid in bboxes:
                prev = bboxes[active_mcid]
                box = [
                    min(prev[0], box[0]), min(prev[1], box[1]),
                    max(prev[2], box[2]), max(prev[3], box[3]),
                ]
            bboxes[active_mcid] = box
    return bboxes


def page_index_for_ref(reader, pg_ref):
    if pg_ref is None:
        return None
    idnum = pg_ref.idnum
    for i, p in enumerate(reader.pages):
        if p.indirect_reference is not None and p.indirect_reference.idnum == idnum:
            return i
    return None


def inject_bboxes(input_path, output_path):
    reader = PdfReader(input_path)
    struct_root = reader.trailer["/Root"].get("/StructTreeRoot")
    if struct_root is None:
        raise SystemExit("No StructTreeRoot found -- is this a tagged PDF?")

    page_bboxes_cache = {}
    fixed = []

    def resolve(o):
        return o.get_object() if isinstance(o, IndirectObject) else o

    def walk(node):
        node = resolve(node)
        if not isinstance(node, DictionaryObject):
            return
        if node.get("/S") == "/Figure":
            k = node.get("/K")
            mcid = None
            if isinstance(k, ArrayObject) and len(k) == 1:
                mcid = int(k[0])
            elif isinstance(k, NumberObject):
                mcid = int(k)
            pg_idx = page_index_for_ref(reader, node.get("/Pg"))
            if mcid is not None and pg_idx is not None:
                if pg_idx not in page_bboxes_cache:
                    page_bboxes_cache[pg_idx] = extract_mcid_bboxes(reader, pg_idx)
                bbox = page_bboxes_cache[pg_idx].get(mcid)
                if bbox is not None:
                    attr = DictionaryObject()
                    attr[NameObject("/O")] = NameObject("/Layout")
                    attr[NameObject("/BBox")] = ArrayObject(FloatObject(v) for v in bbox)
                    existing_a = node.get("/A")
                    if existing_a is None:
                        node[NameObject("/A")] = attr
                    elif isinstance(existing_a, ArrayObject):
                        existing_a.append(attr)
                    else:
                        node[NameObject("/A")] = ArrayObject([resolve(existing_a), attr])
                    fixed.append((str(node.get("/Alt"))[:50], pg_idx, mcid, bbox))
        kids = node.get("/K")
        if kids is None:
            return
        if isinstance(kids, ArrayObject):
            for kk in kids:
                if isinstance(resolve(kk), DictionaryObject):
                    walk(kk)
        elif isinstance(resolve(kids), DictionaryObject):
            walk(kids)

    walk(struct_root)

    writer = PdfWriter(clone_from=reader)
    with open(output_path, "wb") as f:
        writer.write(f)

    print(f"Injected /BBox on {len(fixed)} Figure element(s):")
    for alt, pg_idx, mcid, bbox in fixed:
        print(f"  page {pg_idx} mcid {mcid}: bbox={[round(v, 2) for v in bbox]} alt={alt!r}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python add_figure_bbox.py input.pdf output.pdf")
        sys.exit(1)
    inject_bboxes(sys.argv[1], sys.argv[2])
