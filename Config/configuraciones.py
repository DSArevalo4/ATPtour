class Config:
    """
    Clase de configuración para rutas y parámetros del ETL.
    """
    INPUT_PATH = '/workspaces/ATPtour/tennis_atp_data/atp_matches_2004.csv'  # Ruta del archivo CSV actualizado
    SQLITE_DB_PATH = '/workspaces/ATPtour/Extract/Files/etl_data.db'  # Ruta de la base de datos SQLite
    SQLITE_TABLE = 'atp_matches_2004'  # Nombre de la tabla en la base de datos
