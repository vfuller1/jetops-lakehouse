from pathlib import Path

import pandas as pd


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    source_csv = repo_root / "sample_data" / "orders.csv"
    output_dir = repo_root / "sample_data" / "test"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_parquet = output_dir / "orders_sample.parquet"

    dataframe = pd.read_csv(source_csv)
    dataframe.to_parquet(output_parquet, index=False)

    print(f"Wrote {output_parquet}")


if __name__ == "__main__":
    main()