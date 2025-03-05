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
- Read **total row count** from a file.
- Calculate **batch size** using the **Ceiling function**.
- Generate **XML parameter files** for each batch.
- Execute **Informatica Mapping** via `infacmd.bat`.
- Merge **all XML files** into a final consolidated XML.

#### Key PowerShell Features:
- **Dynamic Batch Calculation:**
  ```powershell
  $incrementValue = [math]::Ceiling($totalRows / $batchCount)
  ```
- **Triggering Informatica Mapping Execution:**
  ```powershell
  Invoke-Expression "infacmd.bat ... -paramFile batchParams.xml"
  ```
- **Parallel Execution Optimization (Future Improvement):**
  Implementing **parallel processing** to speed up execution further.

## Results
✅ Fully **automated** the ETL process.
✅ Efficiently processed **large datasets** while overcoming Informatica's buffer limitation.
✅ Potential for **parallel execution** to enhance performance.

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
1. Update **database connection details** in `data_processing.sql` and execute the script.
2. Modify `process_batches.ps1` with correct paths and parameters.
3. Run the PowerShell script:
   ```powershell
   ./process_batches.ps1
   ```
4. The final merged XML file will be available in the `output/` directory.

## Future Enhancements
- Implement **parallel processing** for faster execution.
- Improve **error handling** and **logging** in the PowerShell script.
- Make the process configurable for **different datasets**.

## License
This project is open-source. Feel free to contribute and improve it!

