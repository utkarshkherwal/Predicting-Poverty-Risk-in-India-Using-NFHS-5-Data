# Predicting Poverty Risk in India Using NFHS-5 Data
This project utilizes data from the National Family Health Survey (NFHS-5) to analyze and predict household poverty risk across India. By combining socioeconomic, demographic, and infrastructure indicators, it aims to identify vulnerable households and provide actionable insights to support targeted policy interventions and resource allocation.

## Data Source

- **NFHS-5 Household Data:**  
  The analysis is based on the household-level microdata collected by the National Family Health Survey (NFHS-5), which covers a wide range of indicators including education, housing, sanitation, and regional variables.

## Methodology

- **Data Preprocessing:**  
  Cleaning, handling missing values, and feature engineering are performed to prepare the dataset for analysis.

- **Statistical Modeling:**  
  Methods such as logistic regression and classification models are used to estimate the likelihood of a household being at risk of poverty based on selected features.

- **Feature Selection:**  
  Key variables include education level, sanitation facilities, housing characteristics, and region.

## Features Used

- Education level (maximum in household)
- Sanitation and water facilities
- Housing type and material
- Region and urban/rural indicator

## Run the analysis

- Update the data file path in the script as needed.
- Execute the main analysis script (e.g., `poverty_rf_debugged.do`).
  
## Results

- The results include summary statistics, model outputs, and visualizations to help understand the factors most associated with household poverty risk.
- Findings can inform policymakers and stakeholders about where interventions may be most needed.

## Acknowledgments

- National Family Health Survey (NFHS-5)
- Contributors to open-source statistical and data analysis libraries
