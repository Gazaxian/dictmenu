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

        # Constrói a janela de exibição (substitui o YAD)
        $form = New-Object System.Windows.Forms.Form
        $form.Text = $palavra_full
        $form.Size = New-Object System.Drawing.Size(480, 420)
        $form.StartPosition = 'CenterScreen'
        $form.FormBorderStyle = 'FixedDialog'
        $form.MaximizeBox = $false

        # Caixa de texto com os detalhes
        $txt = New-Object System.Windows.Forms.TextBox
        $txt.Multiline = $true
        $txt.ReadOnly = $true
        $txt.ScrollBars = 'Vertical'
        $txt.Dock = 'Top'
        $txt.Height = 300
        $txt.Font = New-Object System.Drawing.Font("Consolas", 11)
        
        # Monta o texto de forma limpa
        $textoExibicao = "Palavra: $palavra_full`r`n`r`nExplicação:`r`n$explicacao`r`n`r`nExemplos:`r`n"
        if ($ex1) { $textoExibicao += "1. $ex1`r`n" }
        if ($ex2) { $textoExibicao += "2. $ex2`r`n" }
        if ($ex3) { $textoExibicao += "3. $ex3`r`n" }
        if ($ex4) { $textoExibicao += "4. $ex4`r`n" }
        if ($ex5) { $textoExibicao += "5. $ex5`r`n" }
        
        $txt.Text = $textoExibicao
        $form.Controls.Add($txt)

        # Botão: Repetir Pronúncia
        $btnRepetir = New-Object System.Windows.Forms.Button
        $btnRepetir.Text = "Repetir Pronúncia"
        $btnRepetir.Bounds = New-Object System.Drawing.Rectangle(40, 320, 160, 40)
        $btnRepetir.Add_Click({ $synth.SpeakAsync($palavra_en) | Out-Null })
        $form.Controls.Add($btnRepetir)

        # Botão: Voltar ao Menu
        $btnVoltar = New-Object System.Windows.Forms.Button
        $btnVoltar.Text = "Voltar ao Menu"
        $btnVoltar.Bounds = New-Object System.Drawing.Rectangle(260, 320, 160, 40)
        $btnVoltar.Add_Click({ $form.Close() })
        $form.Controls.Add($btnVoltar)
        # Tira o foco da caixa de texto e passa para o botão "Repetir"
        $form.ActiveControl = $btnRepetir
        # Força a janela a abrir em tamanho normal e pular para frente
        $form.WindowState = 'Normal'
        $form.TopMost = $true
        
        # Tira o foco da caixa de texto e passa para o botão "Repetir"
        $form.ActiveControl = $btnRepetir

        # Exibe a interface e pausa o script até a janela fechar
        $form.ShowDialog() | Out-Null
        
      
          # Sai do sub-loop e volta para a janela de busca principal
        $continuar = $false
    }
}