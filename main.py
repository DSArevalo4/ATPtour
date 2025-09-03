import pandas as pd
from Config.configuraciones import Config  # Importa la clase Config
from Load.atpLoad import Loader  # Importa la clase Loader

# Cargar el archivo CSV
df = pd.read_csv(Config.INPUT_PATH)

# Aquí puedes realizar cualquier transformación que necesites en el DataFrame

# Crear un objeto Loader con el DataFrame limpio
loader = Loader(df)

# Guardar los datos limpios en un archivo CSV
output_csv_path = '/workspaces/ATPtour/Extract/atp_matches_2004_clean.csv'
loader.to_csv(output_csv_path)

# Guardar los datos limpios en la base de datos SQLite
loader.to_sqlite()
