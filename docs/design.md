# Design

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis.
Finally, all this should integrate easily with the usual mathematical operations
and collections that are found in Julia base.

Some considerations:

- We can in principle add quantities with the same dimension (`m [L] + ft [L]`)
- Note that dimensions cannot be determined by exponents: `ft^2` is an area, but so is `acre^1`.
- To avoid overflow issues and general ugliness, we should keep prefixes with units (e.g. `nm` or `km`)
