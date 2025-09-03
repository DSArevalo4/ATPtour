class Extractor:
    """
    Clase para extraer datos de archivos fuente.
    """
    def __init__(self, file_path):
        self.file_path = file_path

    def extract(self):
        """
        Extrae los datos del archivo especificado.
        """
        import pandas as pd
        try:
            df = pd.read_csv("/workspaces/ATPtour/tennis_atp_data/atp_matches_2004.csv")
            return df
        except Exception as e:
            print(f"Error al extraer datos: {e}")
            return None
