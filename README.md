# 2019 parliamentary elections in Poland

### The project
The goal of this project is to analyze and visualize the results of the parliamentary election for the lower house (the Sejm) in Poland in 2019. Typically, seats won and nationwide turnout receive most attention from media outlets. Here I took advanatge of the detailed results from each polling district [pol. *obwodowe komisje wyborcze*] in the coutry, published by the National Electoral Commission, and tried to look deeper into the results.

### The basics
Parliamentary elections in Poland are held every four years. During the elections, all 460 members of the Sejm, the lower house of the parliament, are elected in 41 multi-member electoral districts. The size of electoral districts [pol. *okręg wyborczy*] for the Sejm varies between 600,000 and 1,600,000 inhabitants and determines the number of members elected in that district. Citizens voting abroad elect candidates from the largest, capital district - 'Warszawa I' - independently from their actual place of residence in the country. Each electoral district is served by a number of polling stations [pol. *obwodowa komisja wyborcza*], typically serving 500 to 2000 voters. The voting takes place on Sunday between 7 am and 9 pm. Voters use paper ballots on which single candidate can be selected. Selecting multiple candidates from more than one party-list turns the vote spoiled. Selecting more than one candidate from one party-list only counts as a valid vote towards the highest-positioned among the selected candidates. The votes are counted manually and submitted, along with the summary, to the electoral district office. 

### Datasets
This analysis uses datasets published by the National Electoral Commission [https://sejmsenat2019.pkw.gov.pl/sejmsenat2019/pl/dane_w_arkuszach]. A table from a Wikipedia page [https://pl.wikipedia.org/wiki/Lista_powiatów_w_Polsce] was used as supplementary data.

### Results
This analysis is currently in progress, but partial results are available below:
1) Voting metadata: turnover [here](R/turnover.md)
2) Voting metadata: void votes, etc.
3) Candidates metadata
4) Candidates results
5) Political parties results
