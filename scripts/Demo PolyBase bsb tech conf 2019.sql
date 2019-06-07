/* DEMO POLYBASE BSB TECH CONF 2019 */

-- 1: Create a master key on the database.  -- Required to encrypt the credential secret.  

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'BSBTECHCONF*2019';  

-- 2: Create a database scoped credential  for Azure blob storage.  
-- IDENTITY: any string (this is not used for authentication to Azure storage).  
-- SECRET: your Azure storage account key.  

CREATE DATABASE SCOPED CREDENTIAL BsbTechConfCredential   
WITH IDENTITY = 'stgbsbtechconf', 
Secret = '0SnfCF6fwzcLrnaCwUsnVQqt2BWXJCZ0oebpyRz1Jwm4SydwyO45yLh6KNhm/ATigl90ZuNOZ5TWynCe9J3nbg==';  

-- Query Credential 

select * from sys.database_credentials

-- 3:  Create an external data source.  
-- LOCATION:  Azure account storage account name and blob container name.  
-- CREDENTIAL: The database scoped credential created above.  

CREATE EXTERNAL DATA SOURCE BsbTechConf
with (          
	TYPE = HADOOP, 
	-- 
	LOCATION ='wasbs://bsbtechconf@stgbsbtechconf.blob.core.windows.net',  -- storage container@storageaccount         
	CREDENTIAL = BsbTechConfCredential);  

-- 4:  Create an external file format.  

-- FORMAT TYPE: Type of format in Hadoop (DELIMITEDTEXT,  RCFILE, ORC, PARQUET).  

CREATE EXTERNAL FILE FORMAT CsvFileFormat 
WITH (         FORMAT_TYPE = DELIMITEDTEXT,          
			   FORMAT_OPTIONS 
			   (         FIELD_TERMINATOR =',',            
			   USE_TYPE_DEFAULT = TRUE       ) );

-- 5:  Create an external table.  

-- The external table points to data stored in Azure storage.  
-- LOCATION: path to a file or directory that contains the data (relative to the blob container). 
-- To point to all files under the blob container, use LOCATION='/'


CREATE EXTERNAL TABLE dbo.extcopaintercontinental ( 
	Ano INT NOT NULL, 
	Campeao VARCHAR(150) NOT NULL, 
	ViceCampeao VARCHAR(150) NOT NULL
)
WITH (
	LOCATION='/Copa_Intercontinental.csv',
	DATA_SOURCE= BsbTechConf, FILE_FORMAT=CsvFileFormat
);

-- Query External Table

SELECT 
      [Ano],
      [Campeao],
      [ViceCampeao]
FROM [dbo].[extcopaintercontinental]


CREATE EXTERNAL TABLE dbo.extmundialdeclubes ( 
	Ano INT NOT NULL, 
	Campeao VARCHAR(150) NOT NULL, 
	ViceCampeao VARCHAR(150) NOT NULL
)
WITH (
	LOCATION='/Mundial_de_clubes.csv',
	DATA_SOURCE=BsbTechConf, FILE_FORMAT=CsvFileFormat
);


-- Query External Table

SELECT 
      [Ano],
      [Campeao],
      [ViceCampeao]
FROM [dbo].[extmundialdeclubes]

-- 6: Load data from blob storage to SQL Data Warehouse

-- The CREATE TABLE AS SELECT or CTAS statement is one of the most important T-SQL features available. It is a parallel operation that creates a new table based on the output of a SELECT statement. CTASD is the simplest and -- fastest way to create a copy of a table.

CREATE TABLE [dbo].[copaintercontinental]
WITH (
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX 
) AS
SELECT *  
FROM [dbo].[extcopaintercontinental];

CREATE TABLE [dbo].[mundialdeclubes]
WITH (
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX 
) AS
SELECT *  
FROM [dbo].[extmundialdeclubes];

-- Query table

SELECT count(*)  
FROM [dbo].[copaintercontinental]


-- Clean Demo

DROP EXTERNAL TABLE  [dbo].[extcopaintercontinental]
DROP EXTERNAL TABLE  [dbo].[extmundialdeclubes]

DROP TABLE  [dbo].[extcopaintercontinental]
DROP TABLE  [dbo].[extmundialdeclubes]

/* New catalog views */

SELECT * FROM sys.external_data_sources;  
SELECT * FROM sys.external_file_formats;  
SELECT * FROM sys.external_tables;

/* External Table */

SELECT name, type, is_external FROM sys.tables 

 
