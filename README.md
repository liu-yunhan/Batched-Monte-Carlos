# Batched-Monte-Carlos
A simple example to demonstrate "Batching Stata Monte Carlos: Memory-Safe, Resume-Friendly, and Parallel"

We are working on a more generalized routine so this can be used more easily.

## Requirements:
1. Stata
2. python
3. Git bash

## A quick guide:

edit: 
template.do
create_replications.py

no need to edit:
1.run_do_files
MP
SE

Notes:
The shell script expects that the output from each generated DO file is a dta file with the same name.

In this example, the generated DO files are named mean_r1.do, mean_r2.do, ...

The shell script will move mean_r1.do from generated_dofiles to done_dofiles after it 'sees' mean_r1.dta 
has been created (in a folder named "Outputs").

## Order of operations:

1. Prepare your Monte Carlo do file
2. Transform the do file to a template by
  a. Replacing parameters in the do file with `<<\theta>>`, e.g. `<<i>>`
  b. Remember to `cd ..` at the start of the template so outputs are saved in the root folder.
3. Specify `create_replications.py` to assign parameters and generate the folder of batched do files.
4. Run `1.run_do_files.sh` from Git bash

## Example code to execute in Git bash:

```stata
cd ~/your-folder-here
chmod 700 1.run_do_files.sh
./1.run_do_files.sh
```
