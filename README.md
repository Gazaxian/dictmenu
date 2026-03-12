# dictmenu

![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash\&logoColor=white)
![Linux](https://img.shields.io/badge/platform-Linux-FCC624?logo=linux\&logoColor=black)
![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-active-success)

📚 **dictmenu** is a personal dictionary written in **Bash** with a simple graphical interface using **dmenu + yad** and **automatic pronunciation** powered by `espeak-ng`.

It was created for **fast English vocabulary study directly on Linux**, especially in minimal environments.

---

## ✨ Features

* 🔎 **Fast word search** using `dmenu`
* 📖 Displays:

  * word
  * translation
  * explanation
  * 5 example sentences
* 🔊 **Automatic pronunciation** using `espeak-ng`
* 🔁 Button to **repeat pronunciation**
* 📋 Dictionary stored in a simple **`.txt` file**
* ⚡ **Extremely lightweight** (pure Bash + small utilities)
* 🐧 Perfect for **minimal Linux setups**

---

## 🖼️ How it works

1. The script opens a menu with all words in the dictionary.
2. You select a word using `dmenu`.
3. A `yad` window displays:

   * meaning
   * explanation
   * example sentences
4. The word is **pronounced automatically**.

Simplified flow:

```
dmenu → select word
        ↓
      yad shows
   meaning + examples
        ↓
   espeak-ng pronounces
```

---

## 📦 Dependencies

You need to install:

* `bash`
* `dmenu`
* `yad`
* `espeak-ng`

### Arch / Manjaro

```bash
sudo pacman -S dmenu yad espeak-ng
```

### Debian / Ubuntu

```bash
sudo apt install dmenu yad espeak-ng
```

### Void Linux

```bash
sudo xbps-install -S dmenu yad espeak-ng
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

Each dictionary entry must follow this format:

```
Word (translation)|Explanation|Sentence1|Sentence2|Sentence3|Sentence4|Sentence5
```

### Example

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

## 🐧 Ideal for

* minimal Linux users
* tiling window managers (i3, bspwm, dwm, sway)
* quick vocabulary learning
* people who enjoy simple Bash tools

---

## 📜 License

MIT License
