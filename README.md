# elliptic curves for use with Hyrax

This repository contains elliptic curve parameters for use with pymiracl.

## curve parameters

`mXXX_multi.ecs` define curve parameters for the named curves. Each one also
includes 16384 randomly-generated (via hashing) curve points, which are used
as public parameters for Pedersen commitments.

If you need much larger public parameters, you can generate your own (see
below), or if you want to use the M191 elliptic curve you can download one
of our pre-computed "big" parameter sets. The file `m191big_multi_url` has
links to three such files; download them to this directory and unzip them
if necessary. These files are named `m191big_multi.ecs`, so if you are using
these with [fennel](https://github.com/hyraxZK/fennel) or
[bccgp](https://github.com/hyraxZK/bccgp), you will need to specify `-C m191big`
on the command line.

## generator scripts

The `bin/` directory contains scripts for generating elliptic curve parameters.
These are sage scripts; on Debian-like systems, you should be able to do
something like

    apt-get install sagemath

and then run the scripts with (say) `sage 647.sage`.

- `647.sage` is the original script written by Samuel Neves to validate the
  curve parameters described by Aranha et al. in
  "[A note on high-security general-purpose elliptic curves](https://eprint.iacr.org/2013/647)".

- `gen_ecs.sage` generates the parameters for pymiracl.

- `gen_ecs_multi.sage` generates the parameters for pymiraclvec. Its usage is:
  
  `sage gen_ecs_multi.sage [<nPoints> [<hashString>]]`
  
  where `<nPoints>` is how many random curve points to generate by hashing, and
  `<hashString>` is the initial input to the hash.

## license

`bin/647.sage` was created and is owned by Samuel Neves.

All other files in this repository are released under the following license:

Copyright 2017 Riad S. Wahby <rsw@cs.stanford.edu> and the Hyrax authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
