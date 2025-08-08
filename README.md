# Tourism Attractiveness Comparison Between Countries

## 📌 Project Overview
This project aims to evaluate the tourism attractiveness of countries worldwide by analyzing a variety of objective datasets.

Each country receives an individual score for multiple categories such as cost of living, safety, happiness, and more.

While the scoring system is based on objective data, the weights of the different categories can be customized according to traveler preferences, resulting in a different final score and enabling a dynamic, personalized ranking.

## 📂 Data Sources
The analysis is based on datasets collected from various open data sources, covering different aspects of each country’s appeal to tourists:

**General country data** – basic information such as population, GDP, region, etc.

**Happiness Index** – global happiness rankings

**Crime Index** – safety levels based on crime rates

**Cost of Living data** – average prices and affordability

**Weather conditions** – average temperature, rain and air pollution

**UNESCO World Heritage Sites** – cultural and natural heritage sites

**Nature reserve percentage** – share of protected natural areas

**Number of tourists per year** – annual inbound tourism statistics

## 🛠 Tools & Project Structure
This project was developed using the following tools and formats:

**SQL Server** – For integrating data from various sources, creating scoring Table, and performing analytical queries.

**Excel (CSV files)** – Used for initial data cleaning, assigning category weights, and calculating final country scores.

**PowerPoint (PDF)** – To present the key insights, methodology, and final rankings.

**Main Project Files**
data/ - Raw CSV datasets.

sql/ - SQL scripts for data loading, processing, and scoring.

Tourism_Scoreboard.xlsx - Final scores per country with adjustable weights.

Presentation.pdf - Visual summary of the project’s results.

---
## 📊 Key Insights and results
The analysis showed that tourism appeal depends on a balanced mix of factors—such as safety, culture, nature, and cost—rather than any single one.

In addition, A clear regional trend emerged: Europe dominates the top rankings, while many African countries scored lower, often due to safety and infrastructure gaps.

**🔍 Key Findings**:

**High cost ≠ low tourism** – e.g., Switzerland

**Happier countries** tend to offer better travel experiences

**Weather isn’t decisive** – both rainy and dry countries are popular

**Accessibility helps**, but isn’t critical

**🏆 Top-Ranked Countries (Default Weights)**:

🇲🇽 Mexico, 🇵🇹 Portugal, 🇮🇱 Israel, 🇪🇸 Spain, 🇦🇺 Australia

📄 Full results and visualizations are available in the presentation and final table file

## 🚀 Future Improvements
To enhance both the accuracy and usability of the project, several improvements are planned:

**Expand the model** to include additional factors such as visa requirements, internet access, or cultural offerings.

**Tailor results by traveler type** (e.g., families, backpackers, retirees), with preset weight configurations.

**Develop a simple web interface** to let users adjust preferences and generate personalized rankings.

**Refresh the data periodically** by integrating automated updates or APIs for real-time insights.

## 👤 Author
Created by **Manor Asraf** - Manorasraf@gmail.com
