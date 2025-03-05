# Informatica DEI Data Processor Optimization

## Overview
This project addresses a challenge in **Informatica Data Engineering Integration (DEI) Data Processor**, specifically when converting a **large Oracle table (~5GB)** into **XML files**. The main issue was the **100MB buffer limit**, which prevented processing the entire dataset in a single run. 

## Solution Approach
To resolve this, we implemented a **batch-based processing approach** using:
- **SQL Window Functions (ROW_NUMBER())** to partition the data into smaller batches.
- **Informatica Filter Transformation** to filter data dynamically using parameters.
- **PowerShell Scripting** to automate batch execution and XML file merging.

## Implementation Details
### 1. SQL Partitioning with `ROW_NUMBER()`
We used the `ROW_NUMBER()` function to segment the large dataset and pass it to the **Filter Transformation** in Informatica.

#### SQL Query Example:
```sql
SELECT ROW_NUMBER() OVER (ORDER BY ID) AS RowNum, * FROM SourceTable;
```

### 2. Informatica Filter Transformation
A **Filter Transformation** was used to process data in batches with dynamic parameterization:
```sql
RowNum >= $BTW_1 AND RowNum <= $BTW_2
```
These parameters (`BTW_1`, `BTW_2`) were updated dynamically during execution.

### 3. PowerShell Automation
A **PowerShell script** was developed to:
- Read **total row count** from a file (`Total_Rows.txt`).
- Calculate **batch size** using the **Ceiling function**.
- Generate **XML parameter files** dynamically for each batch.
- Execute **Informatica Mapping** via `infacmd.bat`.
- Wait for batch processing to complete and rename output files.
- Merge **all XML output files** into a final consolidated XML (`Final_Out_DP.xml`).
- Clean up temporary files after execution.

#### PowerShell Execution Flow:
1. Read the total row count from `Total_Rows.txt`.
2. Calculate batch sizes dynamically based on the number of iterations.
3. Generate an XML parameter file (`myparam_ali.xml`) with updated `BTW_1` and `BTW_2` values.
4. Execute the Informatica mapping with the generated parameter file:
   ```powershell
   Invoke-Expression "C:\Informatica\10.4.0\clients\DeveloperClient\infacmd\infacmd.bat ms RunMapping -dn INFA_DOM -sn Data_Integration_Service -un ali.sherif -pd ali.sherif123 -a APP_DP -m MID_DP -pf myparam_ali.xml"
   ```
5. Wait for the output file (`OUTPUT_FILE.out`) to appear and rename it with the batch number.
6. Repeat for all iterations, updating the parameter values dynamically.
7. Merge all generated output files into a final XML file (`Final_Out_DP.xml`).
8. Cleanup temporary files to keep the workspace clean.

## Repository Structure
```
📂 Project Root
│── 📜 README.md  # Documentation
│── 📜 data_processing.sql  # SQL Script for ROW_NUMBER() logic
│── 📜 process_batches.ps1  # PowerShell script for automation
│── 📜 batch_params.xml  # Sample XML parameter file
│── 📂 output/  # Folder containing generated XML files
```

## How to Run
1. Ensure the **database connection details** are configured correctly.
2. Modify `process_batches.ps1` with appropriate paths and credentials.
3. Place `Total_Rows.txt` in the correct directory with the total row count.
4. Execute the PowerShell script:
   ```powershell
   ./process_batches.ps1
   ```
5. After successful execution, the final merged XML will be available in `DP_OUTPUT/Final_Out_DP.xml`.

## Future Enhancements
- Implement **parallel processing** for faster execution.
- Improve **error handling** and **logging** in the PowerShell script.
- Make the process configurable for **different datasets**.

## License
This project is open-source. Feel free to contribute and improve it!

---
Feel free to update the repository with relevant scripts and documentation. 🚀
