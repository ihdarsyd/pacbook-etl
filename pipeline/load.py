import luigi
import logging
import pandas as pd
import time
import sqlalchemy
from datetime import datetime
from pipeline.extract import Extract
from pipeline.utils.db_conn import db_connection
from pipeline.utils.read_sql import read_sql_file
from sqlalchemy.orm import sessionmaker
import os

# Define DIR
DIR_ROOT_PROJECT = os.getenv("DIR_ROOT_PROJECT")
DIR_TEMP_LOG = os.getenv("DIR_TEMP_LOG")
DIR_TEMP_DATA = os.getenv("DIR_TEMP_DATA")
DIR_LOAD_QUERY = os.getenv("DIR_LOAD_QUERY")
DIR_LOG = os.getenv("DIR_LOG")

class Load(luigi.Task):
    
    def requires(self):
        return Extract()
    
    def run(self):
         
        # Configure logging
        logging.basicConfig(filename = f'{DIR_TEMP_LOG}/logs.log', 
                            level = logging.INFO, 
                            format = '%(asctime)s - %(levelname)s - %(message)s')
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Read query to be executed
        try:
            # Read query to truncate pacbook staging schema in dwh
            truncate_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/staging-truncate_tables.sql'
            )
            
            
            logging.info("Read Load Query - SUCCESS")
            
        except Exception:
            logging.error("Read Load Query - FAILED")
            raise Exception("Failed to read Load Query")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Read Data to be load
        try:
            # Read csv
            address = pd.read_csv(self.input()[0].path)
            address_status = pd.read_csv(self.input()[1].path)
            author = pd.read_csv(self.input()[2].path)
            book = pd.read_csv(self.input()[3].path)
            book_author = pd.read_csv(self.input()[4].path)
            book_language = pd.read_csv(self.input()[5].path)
            country = pd.read_csv(self.input()[6].path)
            cust_order = pd.read_csv(self.input()[7].path)
            customer = pd.read_csv(self.input()[8].path)
            customer_address = pd.read_csv(self.input()[9].path)
            order_history = pd.read_csv(self.input()[10].path)
            order_line = pd.read_csv(self.input()[11].path)
            order_status = pd.read_csv(self.input()[12].path)
            publisher = pd.read_csv(self.input()[13].path)
            shipping_method = pd.read_csv(self.input()[14].path)
            
            logging.info(f"Read Extracted Data - SUCCESS")
            
        except Exception:
            logging.error(f"Read Extracted Data  - FAILED")
            raise Exception("Failed to Read Extracted Data")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Establish connections to DWH
        try:
            _, dwh_engine = db_connection()
            logging.info(f"Connect to DWH - SUCCESS")
            
        except Exception:
            logging.info(f"Connect to DWH - FAILED")
            raise Exception("Failed to connect to Data Warehouse")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Truncate all tables before load
        # This puropose to avoid errors because duplicate key value violates unique constraint
        try:            
            # Split the SQL queries if multiple queries are present
            truncate_query = truncate_query.split(';')

            # Remove newline characters and leading/trailing whitespaces
            truncate_query = [query.strip() for query in truncate_query if query.strip()]
            
            # Create session
            Session = sessionmaker(bind = dwh_engine)
            session = Session()

            # Execute each query
            for query in truncate_query:
                query = sqlalchemy.text(query)
                session.execute(query)
                
            session.commit()
            
            # Close session
            session.close()

            logging.info(f"Truncate pacbook staging Schema in DWH - SUCCESS")
        
        except Exception:
            logging.error(f"Truncate pacbook staging Schema in DWH - FAILED")
            
            raise Exception("Failed to Truncate pacbook staging Schema in DWH")
        
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Record start time for loading tables
        start_time = time.time()  
        logging.info("==================================STARTING LOAD DATA=======================================")
        # Load to tables to pacbook staging schema
        try:
            
            try:
                tables = {
                'address': address,
                'address_status': address_status,
                'author': author,
                'book': book,
                'book_author': book_author,
                'book_language': book_language,
                'country': country,
                'cust_order': cust_order,
                'customer': customer,
                'customer_address': customer_address,
                'order_history': order_history,
                'order_line': order_line,
                'order_status': order_status,
                'publisher': publisher,
                'shipping_method': shipping_method
                }

                for table_name, table_data in tables.items():
                    table_data.to_sql(table_name, 
                                    con=dwh_engine, 
                                    if_exists='append', 
                                    index=False, 
                                    schema='staging')
                    logging.info(f"LOAD 'pacbook staging.{table_name}' - SUCCESS")
                    logging.info(f"LOAD All Tables To DWH-pacbook staging - SUCCESS")
                
            except Exception:
                logging.error(f"LOAD All Tables To DWH-pacbook staging - FAILED")
                raise Exception('Failed Load Tables To DWH-pacbook staging')        
        
            # Record end time for loading tables
            end_time = time.time()  
            execution_time = end_time - start_time  # Calculate execution time
            
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Load'],
                'status' : ['Success'],
                'execution_time': [execution_time]
            }

            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write Summary to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/load-summary.csv", index = False)
            
                        
        #----------------------------------------------------------------------------------------------------------------------------------------
        except Exception:
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Load'],
                'status' : ['Failed'],
                'execution_time': [0]
            }

            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write Summary to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/load-summary.csv", index = False)
            
            logging.error("LOAD All Tables To DWH - FAILED")
            raise Exception('Failed Load Tables To DWH')   
        
        logging.info("==================================ENDING LOAD DATA=======================================")
        
    #----------------------------------------------------------------------------------------------------------------------------------------
    def output(self):
        return [luigi.LocalTarget(f'{DIR_TEMP_LOG}/logs.log'),
                luigi.LocalTarget(f'{DIR_TEMP_DATA}/load-summary.csv')]
        