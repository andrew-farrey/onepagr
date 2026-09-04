# Download a URL with a generous timeout and a clear failure message

Internal.
[`download.file()`](https://rdrr.io/r/utils/download.file.html) alone
uses the session's current `options("timeout")` (60 seconds by default),
too short for a Quarto release archive (100+ MB) on anything but a fast
connection. Raises it for the duration of this one call only, always
restored afterward (even on error), and converts any download failure
(no connection, DNS failure, a 404 from a bad `version`) into one clear,
onepagr-specific message instead of
[`download.file()`](https://rdrr.io/r/utils/download.file.html)'s own
low-level error.

## Usage

``` r
download_with_timeout(url, dest, min_timeout = 600)
```

## Arguments

- url:

  Character. URL to download.

- dest:

  Character. Destination file path.

- min_timeout:

  Numeric. Minimum timeout, in seconds, for this download if the
  session's current `options("timeout")` is smaller. Default `600` (10
  minutes), generous for a large release archive on a slow connection.

## Value

Invisibly, `dest`.
