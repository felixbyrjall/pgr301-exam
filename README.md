### PGR301 EKSAMEN 2024 Couch Explorers - Bærekraftig turisme fra sofakroken ! 

Oppgavetekst finner du i [dette](https://github.com/glennbechdevops/eksamen-2024/blob/main/README.md) repoet.

#### Oppgave 1:
- Leveranse 1: https://j8a16eakt7.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/
- Bruk:
  ```json
  {
    "prompt": "tell the ai what you want to see"
  }
  ```
- Leveranse 2: https://github.com/felixbyrjall/pgr301-exam/actions/runs/11996047453/

#### Oppgave 2:
- Leveranse 1: https://github.com/felixbyrjall/pgr301-exam/actions/runs/11996047457
- Leveranse 2: https://github.com/felixbyrjall/pgr301-exam/actions/runs/11996095380
- SQS-kø URL: https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue-19

#### Oppgave 3:
- Taggestrategi:
- **`latest`**: Representerer den nyeste og stabile versjonen for enkel bruk.
- **`1.0.0`**: Bruker semantisk versjonering for formelle utgivelser og tydelig versjonshåndtering.
- **Git SHA (`${{ github.sha }}`)**: Sikrer sporbarhet ved å koble container-imaget til spesifikke commits.
- **Branch-navn (`${{ github.ref_name }}`)**: Støtter flere miljøer som `main` og `feat`.

Denne strategien balanserer brukervennlighet, sporbarhet og fleksibilitet.
- Container image: felixbyrjall/couch-explorer-19
- SQS-kø URL: https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue-19

   ```shell
  docker run -e AWS_ACCESS_KEY_ID=xxx -e AWS_SECRET_ACCESS_KEY=yyy -e SQS_QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue-19 felixbyrjall/couch-explorer-19 "me on top of a pyramid"
   ```

#### Oppgave 4:
- For å kjøre terraform apply lokalt:
   ```shell
   terraform apply -var="notification_email=din@epost.com"
   ```

- Eller kopier `terraform.tfvars.example` til `terraform.tfvars`:
   ```shell
   cp terraform.tfvars.example terraform.tfvars
   ```
- og kjør
   ```shell
  terraform apply
   ```

- For å kjøre Terraform workflow (feks. ved en fork eller git clone)
- Legg til NOTIFICATION_EMAIL i repository secrets med ønsket epost adresse

ApproximateAgeOfOldestMessage threshold er satt til 10 sekunder for å enkelt kunne utløse ALARM

Kode for CloudWatch og SNS er fra linje 158-183 i task_2_and_4/infra/main.tf

#### Oppgave 5:
<p>Når utviklere vurderer å implementere en ny applikasjon, står man overfor et valg mellom to ulike arkitekturmodeller: <br>
serverless med Function-as-a-Service (FaaS) slik som AWS Lambda, eller en mikrotjenestebasert arkitektur. Begge tilnærmingene <br>
har sine fordeler og ulemper, og det er viktig at man som utvikler forstår implikasjonene for sentrale DevOps-prinsipper.</p>


<p>På den ene siden har serverless arkitektur en klar fordel når det gjelder automatisering og kontinuerlig levering (CI/CD).  <br>
Man kan oppdatere funksjonene raskt og uavhengig av hverandre, noe som gir enklere og mer automatiserte prosesser. Det er veldig praktisk,  <br>
siden man slipper å koordinere utrullingen av de ulike, uavhengige tjenestene slik man må gjøre i en mikrotjenestearkitektur.  <br>
Det sistnevnte kan nemlig gjøre det vanskeligere å bruke avanserte deployment-strategier som "blue/green" og "canary".</p>


<p>Når det kommer til observasjonsevnen, altså evnen til å følge med på og få innsikt i applikasjonen, <br>
ser man at dette kan bli mer krevende med en serverless løsning. Ved å miste den direkte kontrollen over infrastrukturen,  <br>
må man i større grad støtte seg på de spesifikke verktøyene som tilbys av tjenesteleverandøren for logging, måling av ytelse og sporbarhet.  <br>
I motsetning til dette, har man bedre oversikt og kontroll i en mikrotjenestearkitektur. Der kan man benytte seg av mer generelle,  <br>
kraftige overvåkningsverktøy som Prometheus og Grafana.</p>


<p>På den andre siden opplever man at en serverless arkitektur har en stor fordel når det kommer til skalerbarhet og kostnadskontroll. <br>
De tjenestene man bruker skalerer automatisk etter etterspørsel, noe som betyr at man slipper å betale for ressurser man ikke bruker.  <br>
Samtidig er kostnadene tydelig knyttet til den faktiske bruken, fremfor å være bundet opp i faste utgifter. På den andre siden, krever <br>
Mikrotjenester mer innsats fra utvikleren når det gjelder overvåkning og konfigurering av skalering, selv om kostnadene er mer forutsigbare.</p>


<p>Når man veier opp disse to arkitekturene så ser man at observasjons mulighetene er større hos mikrotjeneste arkitekturen,  <br>
mens skalerbarhet og kostnadshensyn er bedre hos serverless arkitekturen. Her er det viktig å veie opp hva som er viktigst når en står  <br>
overfor dette valget. Men man kan også ha en hybrid tilnærming, som kan være et bra alternativ for å utnytte fordelene fra begge arkitektur typene.</p>  


<p>Til sist ser man at ansvarsfordelingen er ganske forskjellig i de to arkitektur typene. I en serverless arkitektur overføres en del av ansvaret for infrastruktur og  <br>
plattformstabilitet til leverandøren av FaaS-tjenesten. Det betyr at utvikleren kan fokusere mer på forretningslogikk og funksjonalitet.  <br>
I en mikrotjenestearkitektur har man derimot mer kontroll og ansvar for infrastruktur, skalering, pålitelighet og ytelse for hver enkelt tjeneste.</p>


<p>Så alt i alt har serverless noen fordeler når det gjelder CI/CD og skalerbarhet/kostnader, men ulemper knyttet til observabilitet og ansvar.  <br>
Mikrotjenester gir utvikleren mer kontroll og oversikt, men krever litt mer innsats på CI/CD-siden. Valget kommer an på hva som er viktigst for prosjektet  <br>
og teamets ferdigheten og fokus. Igjen, kan en hybrid være et godt alternativ.</p>
