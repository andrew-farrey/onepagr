# Canonical content now lives in inst/examples/county_choropleth.R (see
# R/example-data.R) so it ships with the package and backs the public
# example_data()/template_data() helpers too. This file just gives it
# the name every test in this suite already expects. map0_path..map4_path
# are basenames only, staged by extra_assets -- see that file's own
# header comment for why.
sample_data_county_choropleth <- example_data("county_choropleth")
