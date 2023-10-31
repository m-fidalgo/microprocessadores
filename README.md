<h1 align="center">Projeto de Microprocessadores</h1>
<p align="center">Projeto desenvolvido como trabalho final da disciplina de Microprocessadores</p>

<br />

## Sobre

O programa desenvolvido é um aplicativo console que aceita comandos do usuário e para cada comando, desempenha uma certa ação na placa DE2 Altera, usando o programa Altera Monitor, a linguagem de montagem do Nios II e os recursos da DE2 Media Computer.

<br />

## Instruções

- Ao ser iniciado, o programa deve mostrar a frase `Entre com o comando:` no terminal e esperar que o usuário entre com algum comando.
- Os comandos são compostos conforme a tabela

| Comando | Ação                                                                                                                                                                                                                          |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 00xx    | Piscar xx-ésimo led vermelho em intervalos de 500ms.                                                                                                                                                                          |
| 01xx    | Cancelar piscagem do xx-ésimo led vermelho.                                                                                                                                                                                   |
| 10      | Cancelar piscagem do xx-ésimo led vermelho.                                                                                                                                                                                   |
| 01xx    | Ler o conteudo das chaves (8 bits – SW7-SW0) e calcular o respectivo número triangular. O resultado deve ser mostrado nos displays de 7 segmentos em decimal.                                                                 |
| 20      | Inicia cronômetro de segundos, utilizando 4 displays de 7 segmentos. Adicionalmente, o botão `KEY1` deve controlar a pausa do cronômetro: se contagem em andamento, deve ser pausada; se pausada, contagem deve ser resumida. |
| 21      | Cancela cronômetro                                                                                                                                                                                                            |

<br />

## Etapas

:heavy_check_mark: Uso de polling para uso da UART

:heavy_check_mark: Exibição da mensagem de início

:heavy_check_mark: Writeback do que o usuário digita na UART

:heavy_check_mark: Identificação dos diferentes comandos

:hourglass_flowing_sand: Piscar o LED vermelho com uso do temporizador

:hourglass_flowing_sand: Cancelar a piscagem do LED

:hourglass_flowing_sand: Cálculo do número triangular e exibição do resultado no display de 7 segmentos

:hourglass_flowing_sand: Inicializar cronômetro e exibir no display

:hourglass_flowing_sand: Uso do KEY1 para controlar o cronômetro
