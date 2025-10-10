"""
Minimal generator: creates 100 Stata .do file from a template by substituting <<r>>.

Usage:
    python create_replications.py
Output:
    ./generated/mean_r1.do
Requires:
    - template_mean.do in the same folder
"""

from pathlib import Path

HERE = Path(__file__).parent
TEMPLATE = HERE / "template_mean.do"
OUTDIR = HERE / "generated_dofiles"
OUTDIR.mkdir(parents=True, exist_ok=True)

def make_do(r: int) -> Path:
    content = TEMPLATE.read_text()
    content = content.replace("<<r>>", str(r))
    out = OUTDIR / f"mean_r{r}.do"
    out.write_text(content)
    return out

if __name__ == "__main__":
    r_values = range(1,101)  # per spec: create 100 version indexed by r
    created = [make_do(r) for r in r_values]
    print(f"Created {len(created)} file(s):")
    for p in created:
        print(" -", p)
