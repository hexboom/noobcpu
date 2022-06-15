## ver0.1
1. single cycle 
2. most I isa (without ecall ebreak), csrrw, csrrwi

## ver1.0
1. 5 stages pipline, reconstruct the controller module
2. implement most RV32I isa (except ecall ebreak)
3. delete the implementation of csrrw, csrrwi
4. pass most isa test (except load sh sb fence)
5. implement forward module and hazard_detecion module to solve the control hazard and data hazard
6. write simple assembly program to test hazard solving modules
7. change regfile to write with negedge of clk
8. add bios memory and change imem to dual ports

## ver1.1 (pre)
1. perfect bios memory
2. implement csrrw, csrrwi
3. perfect simulation using eecs151

## ver2.0 (pre)
1. add uart
2. add mmio module
3. test on fpga

## ver3.0 (pre)
1. add ahb/axi
2. implement r32m