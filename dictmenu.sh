#!/bin/bash

ARQ="$HOME/Scripts/wordlist.txt"

# Criar arquivo caso não exista
if [ ! -f "$ARQ" ]; then

    yad --question \
        --title="Dicionário não encontrado" \
        --text="O arquivo wordlist.txt não foi encontrado.\n\nDeseja criá-lo agora?"

    resposta=$?

    if [ "$resposta" -eq 0 ]; then
        mkdir -p "$HOME/Scripts"

        # Modelo inicial do arquivo
        cat <<EOF > "$ARQ"
# Formato do Dicionário
# Palavra (tradução)|Explicação|Exemplo1 en - pt|Exemplo2 en - pt|Exemplo3 en - pt|Exemplo4 en - pt|Exemplo5 en - pt
EOF

        yad --info --text="Arquivo criado em:\n$ARQ"
    else
        exit 1
    fi
fi


lista() {
    cut -d '|' -f 1 "$ARQ" | grep -v "^#" | sort -f
}

# LOOP principal
while true; do

    escolha=$(lista | dmenu -i \
        -l 20 \
        -sb '#137824' \
        -fn 'DejaVu Sans-14' \
        -p "Escolha a palavra:")

    [ -z "$escolha" ] && exit 0

    linha=$(grep -i "^$escolha" "$ARQ")

    [ -z "$linha" ] && {
        yad --error --text="Entrada não encontrada!"
        continue
    }

    palavra_full=$(echo "$linha" | cut -d '|' -f 1)
    explicacao=$(echo "$linha" | cut -d '|' -f 2)

    frase1=$(echo "$linha" | cut -d '|' -f 3)
    frase2=$(echo "$linha" | cut -d '|' -f 4)
    frase3=$(echo "$linha" | cut -d '|' -f 5)
    frase4=$(echo "$linha" | cut -d '|' -f 6)
    frase5=$(echo "$linha" | cut -d '|' -f 7)

    # extrair palavra sem tradução
    palavra_en=$(echo "$palavra_full" | sed -E 's/ \(.+\)//')

    while true; do

        # fala automática
        espeak-ng -v en-us "$palavra_en" &

        yad --title="$palavra_full" \
            --center --width=480 --height=380 \
            --button="Repetir Pronúncia:0" \
            --button="Voltar ao Menu:1" \
            --text="<b>$palavra_full</b>

<b>Explicação:</b>
$explicacao

<b>Exemplos:</b>
1. $frase1
2. $frase2
3. $frase3
4. $frase4
5. $frase5
"

        resposta=$?

        if [ "$resposta" -eq 0 ]; then
            espeak-ng -v en-us "$palavra_en"
            continue
        fi

        if [ "$resposta" -eq 1 ]; then
            break
        fi

    done

done