# PART A: Mathematical Functions

In this section, I focused on implementing fundamental matrix operations commonly used in neural networks. Specifically, I developed functions for dot product, matrix multiplication, element-wise ReLU, and ArgMax.

All matrices were represented as 1D vectors in row-major order. This representation required careful attention to memory access patterns, particularly when working with strides to access elements non-contiguously in memory.

---

## Challenges and Solutions

### 1. Input Handling: Flattening the 2D Matrix
**Challenge:**  
Transforming a 2D matrix into a 1D vector was the first hurdle. Working with MNIST-like data, I had to ensure that the flattened representation accurately followed the row-major order.

**Solution:**  
Through precise index calculations, I ensured that each row of the 2D matrix was concatenated correctly. This set a solid foundation for subsequent matrix operations.

---

### 2. ReLU Implementation
**Implementation:**  
ReLU was implemented by looping through the input array, using the index `i` as a pointer to process each value individually. Negative values were replaced with zero.

**Challenge:**  
The VENUS system call requires `a0` as the control register. During static data testing, using `a0` for output caused conflicts when performing system calls.

**Solution:**  
To resolve this, I temporarily stored output in `a1` before making system calls, ensuring that `a0` could properly control the output.

---

### 3. ArgMax Implementation
**Implementation:**  
ArgMax was based on a "max register" function. The algorithm iterated through the array, comparing each element and updating the "reg_kingdom" (max value register) when a new maximum was found. Simultaneously, it tracked the corresponding index of the maximum value.

---

### 4. Dot Product Implementation
**Thought Process:**  
- **Version 1:**  
  The initial implementation focused on functionality, assuming both arrays had the same stride. Sizes `size1` and `size2` were independently configurable.
  
  ⚠️ **Key Issues:**  
  - The dot product’s role in `matmul` assumes `stride1` = 1 and `stride2` = `matrixB_col`. 
  - The sizes of both arrays must match by design.

- **Version 2 (Improvements):**  
  Added the ability to handle different strides (`stride1` and `stride2`).

  🔑 **Key Insights:**  
  - For `matmul`, `stride1` is always 1, while `stride2` typically exceeds 1 (e.g., the number of columns in matrix B).

  Additionally, I reduced the number of registers by combining `size1` and `size2` into a single size register.

**Future Improvements:**  
Develop a version where both `stride1` and `stride2` can be independently configurable, enhancing the function's general utility.

---

### 5. Matrix Multiplication (MatMul) Implementation
**Implementation:**  
Matrix multiplication was achieved by calculating the dot product between rows of `M1` and columns of `M2`. This process repeated for each pair, with the total number of computations equaling `M1_col_number` × `M2_row_number`.

---

## Key Takeaways from PART A

### 1. Static Memory Allocation for Testing  
Throughout PART A, I learned to define static memory in the data segment for testing each function. This approach allowed for easy verification of function outputs without worrying about dynamic memory issues during initial development.

---

### 2. Debugging with VENUS Web Simulator  
Debugging assembly can be daunting, but **VENUS Web Simulator** proved invaluable. By stepping through each instruction and observing register values, I could pinpoint errors. Setting breakpoints using `EBREAK` allowed me to halt execution at critical points, making the debugging process more manageable and systematic.

---

### 3. Mastery of Function Calling Conventions  
Implementing these functions solidified my understanding of **RISC-V calling conventions**. Specifically:

- **Caller-saved registers** (`reg_a`, `reg_t`) were used for temporary values.
- **Callee-saved registers** (`reg_s`, `reg_ra`) ensured that critical values were preserved across function calls.

Through practice, I became adept at crafting robust **prologue** and **epilogue** sections for each function, ensuring that register states were properly saved and restored.

---

## Final Reflection on PART A  
This section was a deep dive into low-level programming and assembly concepts. It challenged my understanding of memory management, register handling, and function calling conventions. By the end, I felt more confident in writing efficient, bug-free assembly code, a foundational skill for building more complex systems in the future.



# PART B: File Operations and Main Integration

In this section, I tackled the challenges of handling file operations and integrating various functions to build a cohesive program. The goal was to manage data efficiently, ensure smooth transitions between functions, and debug effectively in a complex environment.

---

## Challenges and Solutions

### 2. Overwriting of `reg_a` in Functions
- **Problem:**  
  The `reg_a` registers, used for input values, were often overwritten during function calls, leading to data loss.

- **Solution:**  
  At the beginning of each function, all input values were backed up into `reg_s` registers to ensure data integrity.

---

### 3. Reproducing Development Environment with Virtual Environments
- **Problem:**  
  Cloning the instructor's project via `git` required a specific environment setup to avoid compatibility issues.

- **Solution:**  
  By creating a virtual environment using `requirements.txt` or `environment.yml`, I ensured consistency across different systems, replicating the exact development environment.

---

### 4. Setting Breakpoints for Debugging
- **Problem:**  
  Identifying specific failure points was difficult in a complex sequence of operations.

- **Solution:**  
  The `EBREAK` instruction was used to pause execution at critical points, enabling step-by-step analysis of register values and memory states.
  ```assembly
  ebreak

### 5. Managing Multiple Outputs
- **Problem:**  
  Managing multiple return values in a function was challenging.

- **Solution:**  
  1. **Direct Output:** Use `a0` and `a1` for two outputs.  
  2. **Memory-Based Output:** Store results in consecutive memory addresses and return the base address in `a0`.  
  3. **Global Variables:** Define global variables to store results.

### 6. Misuse of `lw` and `la` Instructions
- **Problem:**  
  Incorrectly using `la` for registers instead of labels:
  ```assembly
  la t0, a0  # Incorrect: a0 is a register, not a label.
  ```
- **Solution**:
  
  lw: Load a value from a memory address.
  la: Load the address of a label.
  For copying between registers, use mv:
    ```assembly
    mv t0, a0  # Correct: Copies the value from a0 to t0.
    ```
### 7. Efficient Register Usage
- **Problem:**  
  Improper use of registers led to unnecessary overwrites and data loss.

- **Solution:**  
  - **`reg_t`:** Used for temporary computations.  
  - **`reg_s`:** Used for persistent values across loops or function calls.  
  - **`reg_a`:** Used for function inputs.

**Key Insight:**  
Proper management of Caller-saved (`reg_a`, `reg_t`) and Callee-saved (`reg_s`, `reg_ra`) registers ensures data consistency during nested function calls.

---

### 8. Stack Management and Function Integration
- **Problem:**  
  Incorrect stack usage caused memory conflicts during function calls.

- **Solution:**  
  Ensure proper storage and retrieval of values using the stack:
  ```assembly
  addi sp, sp, -8  # Allocate stack space
  sw ra, 4(sp)     # Save return address
  sw a0, 0(sp)     # Save input value
## Key Takeaways

### Debugging Techniques
- **VENUS Web Simulator** enabled visualization of execution flow and register states.  
- **Breakpoints with EBREAK** provided precise control for troubleshooting.

### Function Modularity
- Following **RISC-V calling conventions** ensured robust function design.  
- Clear **Prologue** and **Epilogue** structures safeguarded register and memory management.

### Incremental Development Approach
- Testing and implementing functions incrementally allowed quick identification and resolution of bugs, ensuring steady progress.

---

## Reflection on PART B
This section enhanced my understanding of file operations, register management, and function integration in RISC-V assembly. The debugging and optimization processes prepared me for tackling more complex system-level programming challenges in the future.