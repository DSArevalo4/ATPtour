import pandas as pd



# Leer el archivo CSV (asegurándose de que el delimitador sea el correcto)
df = pd.read_csv("/workspaces/ATPtour/tennis_atp_data/atp_matches_2004.csv")

# Verificar las primeras filas para inspección
print("Primeras filas del archivo original:")
print(df.head())

# 1. Eliminar duplicados
df = df.drop_duplicates()
print(f"Filas después de eliminar duplicados: {df.shape[0]}")

# 2. Eliminar filas con valores vacíos en columnas clave (opcional, si se conoce que alguna columna es crítica)
df = df.dropna()
print(f"Filas después de eliminar filas vacías: {df.shape[0]}")

# 3. Normalizar nombres de columnas (quitar espacios, poner en minúsculas, reemplazar espacios por guiones bajos)
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")

# Verificación después de la limpieza de columnas
print("Nombres de columnas normalizados:")
print(df.columns)

# 4. Guardar el archivo limpio
df.to_csv("Stores_clean.csv", index=False)

print("CSV limpio guardado en 'Stores_clean.csv'")