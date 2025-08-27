import pandas as pd

# Cargar el archivo CSV
file_path = '/workspaces/ATPtour/tennis_atp_data/atp_matches_2004.csv'
df = pd.read_csv(file_path)

# Mostrar las primeras filas del dataframe para entender su estructura
print (df.head())