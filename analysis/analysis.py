import os
import re
import glob
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def find_match_files(base_dir='tennis_atp_data'):
    pattern = os.path.join(base_dir, 'atp_matches_*.csv')
    files = [f for f in glob.glob(pattern) if 'doubles' not in f and 'amateur' not in f]
    files.sort()
    return files


def read_and_concatenate(files):
    frames = []
    for f in files:
        try:
            df = pd.read_csv(f, low_memory=False)
        except Exception as e:
            print(f"Warning: Could not read {f}: {e}")
            continue

        # Derive year: prefer tourney_date if present, fallback to filename
        if 'tourney_date' in df.columns:
            df['year'] = pd.to_datetime(df['tourney_date'], format='%Y%m%d', errors='coerce').dt.year
        elif 'tourney_year' in df.columns:
            df['year'] = df['tourney_year']
        else:
            m = re.search(r'atp_matches_(\d{4})', f)
            df['year'] = int(m.group(1)) if m else pd.NA

        # Ensure required columns exist
        if 'surface' not in df.columns:
            df['surface'] = 'unknown'
        if 'winner_name' not in df.columns:
            # try alternative column names
            if 'winner' in df.columns:
                df['winner_name'] = df['winner']
            else:
                df['winner_name'] = pd.NA

        frames.append(df[['year', 'surface', 'winner_name']])

    if frames:
        full = pd.concat(frames, ignore_index=True)
    else:
        full = pd.DataFrame(columns=['year', 'surface', 'winner_name'])
    return full


def plot_matches_per_year_surface(df, outpath):
    df2 = df.dropna(subset=['year'])
    df2['year'] = df2['year'].astype(int)

    grp = df2.groupby(['year', 'surface']).size().unstack(fill_value=0)

    plt.figure(figsize=(12, 6))
    grp.plot(kind='bar', stacked=True, colormap='tab20', width=0.8)
    plt.title('Número de partidos por año y superficie')
    plt.xlabel('Año')
    plt.ylabel('Partidos')
    plt.tight_layout()
    plt.savefig(outpath)
    plt.close()


def plot_top10_winners(df, outpath):
    wins = df['winner_name'].dropna().value_counts().head(10)[::-1]
    plt.figure(figsize=(8, 6))
    sns.barplot(x=wins.values, y=wins.index, palette='deep')
    plt.xlabel('Victorias (conteo)')
    plt.title('Top 10 jugadores por número de victorias (todas las temporadas)')
    plt.tight_layout()
    plt.savefig(outpath)
    plt.close()


def main():
    print('Buscando archivos de partidos...')
    files = find_match_files()
    print(f'Archivos encontrados: {len(files)}')
    if not files:
        print('No se encontraron archivos. Asegúrate de que la carpeta `tennis_atp_data` exista.')
        return

    df = read_and_concatenate(files)
    print(f'Total registros cargados: {len(df)}')

    out_dir = 'outputs'
    os.makedirs(out_dir, exist_ok=True)

    p1 = os.path.join(out_dir, 'matches_per_year_surface.png')
    p2 = os.path.join(out_dir, 'top10_winners.png')

    print('Generando gráfica 1: matches por año y superficie...')
    plot_matches_per_year_surface(df, p1)
    print(f'Gráfica guardada en: {p1}')

    print('Generando gráfica 2: top 10 ganadores...')
    plot_top10_winners(df, p2)
    print(f'Gráfica guardada en: {p2}')


if __name__ == '__main__':
    main()
