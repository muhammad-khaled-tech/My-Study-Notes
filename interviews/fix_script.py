with open("/home/mkhaled/Desktop/mohamed khaled /ITI open source applications devolpment/My Study Notes/interviews/Django & DRF من الصفر — إنترفيو الباك إند.md", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Find where Q10 ends. I appended Q21 at line 782.
# "## الجزء الخامس" is at line 782. Let's find it.
index = -1
for i, line in enumerate(lines):
    if "## الجزء الخامس" in line:
        index = i
        break

if index != -1:
    lines = lines[:index]
    with open("/home/mkhaled/Desktop/mohamed khaled /ITI open source applications devolpment/My Study Notes/interviews/Django & DRF من الصفر — إنترفيو الباك إند.md", "w", encoding="utf-8") as f:
        f.writelines(lines)
    print(f"Truncated at line {index}")
else:
    print("Not found")
