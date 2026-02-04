# Como subir o projeto no GitHub

Guia passo a passo para publicar este repositório no seu GitHub e compartilhar com recrutadores.

---

## Antes de subir

### 1. Verificar o que NÃO será enviado

O arquivo `.gitignore` já evita que arquivos sensíveis ou desnecessários sejam commitados. **Confira que estes NÃO estão na lista ao rodar `git add .`:**

- `etl/config.yaml` — contém seu `project_id` do GCP (não deve ser público)
- Qualquer arquivo `*.json` de credenciais (service account, etc.)
- Pastas `venv/`, `__pycache__/`, `.idea/`, etc.

### 2. O que SERÁ enviado

- Todo o código (SQL, Python, YAML de exemplo)
- CSVs em `data/`
- Toda a documentação em `docs/` e `dashboards/`
- README.md, LICENSE, .gitignore, requirements.txt
- `etl/config.example.yaml` (modelo sem dados reais)

---

## Opção A — Repositório novo no GitHub (recomendado)

### Passo 1: Criar o repositório no GitHub

1. Acesse [https://github.com/new](https://github.com/new).
2. **Repository name:** por exemplo `autotech-ga4-gcp-analytics` ou `AutoTechB2B-Analytics`.
3. **Description (opcional):** "Portfolio project: B2B Analytics pipeline with GA4, BigQuery and Looker Studio".
4. Escolha **Public** (para compartilhar com recrutadores).
5. **Não** marque "Add a README file", "Add .gitignore" ou "Choose a license" — o projeto já tem esses arquivos.
6. Clique em **Create repository**.

### Passo 2: Inicializar Git e fazer o primeiro commit (no seu PC)

Abra o **PowerShell** ou **Prompt de comando** na pasta do projeto:

```powershell
cd C:\Users\dopamine\Desktop\Projetos\AutoTechB2B
```

Se esta pasta **ainda não** é um repositório Git:

```powershell
git init
git add .
git status
```

Revise a saída de `git status`. **Não** deve aparecer `etl/config.yaml`. Se aparecer, não faça `git add etl/config.yaml` (ou remova do staging: `git reset etl/config.yaml`).

```powershell
git commit -m "feat: projeto completo AutoTech B2B Analytics - GA4, BigQuery, Looker Studio"
git branch -M main
```

### Passo 3: Conectar ao GitHub e enviar

Substitua `SEU_USUARIO` pelo seu usuário do GitHub e `NOME_DO_REPO` pelo nome que você escolheu (ex.: `autotech-ga4-gcp-analytics`):

```powershell
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git
git push -u origin main
```

Exemplo:

```powershell
git remote add origin https://github.com/josedosantos/autotech-ga4-gcp-analytics.git
git push -u origin main
```

Se o GitHub pedir autenticação:

- **HTTPS:** use um **Personal Access Token** (GitHub → Settings → Developer settings → Personal access tokens) como senha.
- **SSH:** use uma URL como `git@github.com:SEU_USUARIO/NOME_DO_REPO.git` e tenha a chave SSH configurada.

---

## Opção B — A pasta já é um repositório Git

Se você já rodou `git init` antes:

```powershell
cd C:\Users\dopamine\Desktop\Projetos\AutoTechB2B
git add .
git status
git commit -m "docs: README profissional e documentação completa para portfólio"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git
git push -u origin main
```

Se o `remote` já existir mas apontar para outro repositório:

```powershell
git remote set-url origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git
git push -u origin main
```

---

## Depois de subir

1. **README:** O README.md será exibido na página do repositório. Revise no GitHub se está tudo certo.
2. **Link para recrutadores:** Envie o link do repositório, por exemplo:  
   `https://github.com/SEU_USUARIO/autotech-ga4-gcp-analytics`
3. **Sobre o repositório:** No GitHub, clique em **About** (à direita) → engrenagem → marque **Topics** (ex.: `analytics`, `bigquery`, `ga4`, `looker-studio`, `data-engineering`, `portfolio`).
4. **Dashboard:** Se quiser, adicione na descrição ou no README o link do relatório Looker Studio (se for público) ou mencione que o dashboard foi construído no Looker Studio conectado ao BigQuery.

---

## Mensagens de commit sugeridas (futuras alterações)

| Situação | Exemplo de mensagem |
|----------|----------------------|
| Nova funcionalidade | `feat: adiciona view analytics por segmento` |
| Correção | `fix: ajuste de tipo na tabela raw_ga4_events` |
| Só documentação | `docs: atualiza passo a passo do dashboard` |
| Manutenção | `chore: atualiza dependências no requirements.txt` |

---

## Checklist rápido antes do push

- [ ] `etl/config.yaml` não está sendo commitado (está no .gitignore)
- [ ] Nenhum arquivo de credenciais (.json de service account) na pasta
- [ ] README.md está atualizado e profissional
- [ ] Repositório criado no GitHub (vazio, sem README/.gitignore/license)
- [ ] `git remote add origin` com a URL correta do seu usuário e nome do repo
- [ ] `git push -u origin main` executado com sucesso
