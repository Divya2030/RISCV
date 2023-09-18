import cocotb
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge

@cocotb.coroutine
def alu_basic_test(dut, a, b, alu_ctrl, expected_result):
    """A basic test for the ALU module"""
    
    # Set the input values
    dut.a <= a
    dut.b <= b
    dut.alu_ctrl <= alu_ctrl
    
    # Wait for a clock edge to allow the ALU to process the inputs
    yield RisingEdge(dut.clk)
    
    # Check the output
    assert dut.result.value == expected_result, f"ALU output was {dut.result.value}, expected {expected_result}"

# Create a test factory
tf = TestFactory("alu_basic_test")
tf.add_option("-sv")
tf.generate_tests()

