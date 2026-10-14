# Descobre a pasta onde este script (.ps1) está salvo
$ArqDir = $PSScriptRoot

# Proteção: caso o script seja rodado direto no terminal sem estar salvo em um arquivo
if ([string]::IsNullOrEmpty($ArqDir)) { $ArqDir = (Get-Location).Path }

# Define o caminho do TXT na mesma pasta do script
$ArqPath = Join-Path -Path $ArqDir -ChildPath "wordlist.txt"

# Carrega os módulos gráficos e de voz do Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Speech

# 1. Criar arquivo caso não exista
if (-Not (Test-Path $ArqPath)) {
    $msg = "O arquivo wordlist.txt não foi encontrado nesta pasta.`n`nDeseja criá-lo agora?"
    $res = [System.Windows.Forms.MessageBox]::Show($msg, "Dicionário não encontrado", 4) # 4 = Sim/Não
    
    if ($res -eq 'Yes') {
        $template = @"
# Formato do Dicionário
# Palavra (tradução)|Explicação|Exemplo1 en - pt|Exemplo2 en - pt|Exemplo3 en - pt|Exemplo4 en - pt|Exemplo5 en - pt
"@
        Set-Content -Path $ArqPath -Value $template -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show("Arquivo criado em:`n$ArqPath", "Informação")
    } else { 
        exit 
    }
}

# 2. Configurar Voz (TTS)
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
# Tenta pegar a primeira voz em inglês instalada no sistema
$voice = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Culture -like 'en-*' } | Select-Object -First 1
if ($voice) { $synth.SelectVoice($voice.VoiceInfo.Name) }

# 3. LOOP principal
while ($true) {
    # Lê o arquivo ignorando comentários e linhas em branco
    $linhas = Get-Content $ArqPath -Encoding UTF8 | Where-Object { $_ -notmatch "^#" -and $_.Trim() -ne "" }
    if (-not $linhas) { 
        [System.Windows.Forms.MessageBox]::Show("O dicionário está vazio! Adicione palavras ao wordlist.txt.", "Aviso")
        exit 
    }

    # Janela de busca nativa do PowerShell (substitui o dmenu)
    $escolha = $linhas | ForEach-Object { ($_ -split '\|')[0] } | Sort-Object | Out-GridView -Title "Escolha a palavra" -OutputMode Single
    
    # Se o usuário fechar a janela de seleção ou clicar em cancelar
    if (-not $escolha) { exit }

    # Recupera a linha completa baseada na escolha
    $linha = $linhas | Where-Object { $_ -like "$escolha|*" } | Select-Object -First 1
    $partes = $linha -split '\|'
    
    # Preenche as variáveis para evitar erros caso faltem exemplos no TXT
    $palavra_full = $partes[0]
    $explicacao   = if ($partes.Count -gt 1) { $partes[1] } else { "" }
    $ex1          = if ($partes.Count -gt 2) { $partes[2] } else { "" }
    $ex2          = if ($partes.Count -gt 3) { $partes[3] } else { "" }
    $ex3          = if ($partes.Count -gt 4) { $partes[4] } else { "" }
    $ex4          = if ($partes.Count -gt 5) { $partes[5] } else { "" }
    $ex5          = if ($partes.Count -gt 6) { $partes[6] } else { "" }
    
    # Remove a tradução entre parênteses para a pronúncia correta em inglês
    $palavra_en = $palavra_full -replace ' \(.+\)', ''

    $continuar = $true
    while ($continuar) {
        
        # Fala automática (assíncrona para não travar a interface)
        $synth.SpeakAsync($palavra_en) | Out-Null

        # Janela de exibição com interface mais limpa e legível
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Dicionário - $palavra_full"
        $form.Size = New-Object System.Drawing.Size(720, 560)
        $form.StartPosition = 'CenterScreen'
        $form.FormBorderStyle = 'FixedDialog'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::White
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

        # Título da palavra
        $lblPalavra = New-Object System.Windows.Forms.Label
        $lblPalavra.Text = $palavra_full
        $lblPalavra.Location = New-Object System.Drawing.Point(25, 20)
        $lblPalavra.Size = New-Object System.Drawing.Size(655, 40)
        $lblPalavra.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $lblPalavra.ForeColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
        $form.Controls.Add($lblPalavra)

        # Área de texto
        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Multiline = $true
        $txt.ReadOnly = $true
        $txt.ScrollBars = 'Vertical'
        $txt.Location = New-Object System.Drawing.Point(25, 75)
        $txt.Size = New-Object System.Drawing.Size(655, 365)
        $txt.Font = New-Object System.Drawing.Font("Segoe UI", 11)
        $txt.BackColor = [System.Drawing.Color]::FromArgb(248, 248, 248)
        $txt.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
        $txt.BorderStyle = 'FixedSingle'

        # Mantém exatamente as mesmas informações exibidas pela versão original
        $textoExibicao = "Palavra: $palavra_full`r`n`r`nExplicação:`r`n$explicacao`r`n`r`nExemplos:`r`n"
        if ($ex1) { $textoExibicao += "`r`n1. $ex1`r`n" }
        if ($ex2) { $textoExibicao += "`r`n2. $ex2`r`n" }
        if ($ex3) { $textoExibicao += "`r`n3. $ex3`r`n" }
        if ($ex4) { $textoExibicao += "`r`n4. $ex4`r`n" }
        if ($ex5) { $textoExibicao += "`r`n5. $ex5`r`n" }

        $txt.Text = $textoExibicao
        $form.Controls.Add($txt)

        # Botão: Repetir Pronúncia
        $btnRepetir = New-Object System.Windows.Forms.Button
        $btnRepetir.Text = "Repetir Pronúncia"
        $btnRepetir.Location = New-Object System.Drawing.Point(25, 460)
        $btnRepetir.Size = New-Object System.Drawing.Size(205, 42)
        $btnRepetir.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnRepetir.Add_Click({ $synth.SpeakAsync($palavra_en) | Out-Null })
        $form.Controls.Add($btnRepetir)

        # Botão: Voltar ao Menu
        $btnVoltar = New-Object System.Windows.Forms.Button
        $btnVoltar.Text = "Voltar ao Menu"
        $btnVoltar.Location = New-Object System.Drawing.Point(475, 460)
        $btnVoltar.Size = New-Object System.Drawing.Size(205, 42)
        $btnVoltar.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnVoltar.Add_Click({ $form.Close() })
        $form.Controls.Add($btnVoltar)

        $form.ActiveControl = $btnRepetir
        $form.WindowState = 'Normal'
        $form.TopMost = $true

        # Exibe a interface e pausa o script até a janela fechar
        $form.ShowDialog() | Out-Null

      
          # Sai do sub-loop e volta para a janela de busca principal
        $continuar = $false
    }
}
