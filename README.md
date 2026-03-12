# dictmenu

📚 A personal **Bash dictionary** with **dmenu + yad** interface and **automatic pronunciation** using `espeak-ng`.

Created for fast English vocabulary study on Linux.

---

## ✨ Features

* 🔎 Fast word search using **dmenu**
* 📖 Displays:

  * word
  * translation
  * explanation
  * 5 example sentences
* 🔊 Automatic pronunciation with **espeak-ng**
* 🔁 Button to repeat pronunciation
* 📋 Simple `.txt` based dictionary
* ⚡ Extremely lightweight (pure Bash)

---

## 🖼️ How it works

1. The script opens a menu with all words.
2. You select a word.
3. A window shows the meaning and examples.
4. The word pronunciation plays automatically.

---

## 📦 Dependencies

Install:

* bash
* dmenu
* yad
* espeak-ng

Arch Linux:

```bash
sudo pacman -S dmenu yad espeak-ng
```

Debian / Ubuntu:

```bash
sudo apt install dmenu yad espeak-ng
```

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/Gazaxian/dictmenu.git
```

Enter the directory:

```bash
cd dictmenu
```

Make the script executable:

```bash
chmod +x dictmenu
```

Run:

```bash
./dictmenu
```

---

## 📄 wordlist.txt format

Each line must follow this structure:

```
Word (translation)|Explanation|Sentence1|Sentence2|Sentence3|Sentence4|Sentence5
```

Example:

```
Yourself (você mesmo)|Refers to the same person.|Take care of yourself. - Cuide de você mesmo.|Do it yourself. - Faça você mesmo.|Be proud of yourself. - Tenha orgulho de si mesmo.|Control yourself. - Controle-se.|Treat yourself kindly. - Trate-se com gentileza.
```

Lines starting with `#` are ignored.

---

## 📂 Project structure

```
dictmenu/
 ├── dictmenu
 ├── wordlist.txt
 ├── README.md
 └── LICENSE
```

---

## 🐧 Perfect for

* minimal Linux users
* tiling window managers (i3, bspwm, dwm)
* quick vocabulary learning

---

## 📜 License

MIT License
