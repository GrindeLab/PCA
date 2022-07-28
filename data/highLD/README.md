# High LD Regions

We performed an extensive literature review and identified regions with high, extensive, or otherwise unusual LD that are often recommended for exclusion before running PCA. 
The original papers reported the locations of these regions in build 36, but we also created versions of this list in more recent builds 37 and 38 using [liftover](https://genome.ucsc.edu/cgi-bin/hgLiftOver).
Note that there were some conversions that failed---more details below.

## Build 36 to Build 37 Conversion Errors

```
#Split in new
chr2	85941853	100500000	michigan2_anderson2_price2
#Partially deleted in new
chr3	89000000	97500000	michigan7_price7
#Partially deleted in new
chr5	44000000	51500000	fellay1_anderson6_michigan8_price8
#Partially deleted in new
chr6	57000000	64000000	anderson9_michigan13_price13
#Partially deleted in new
chr7	55000000	66193285	anderson11_price15_michigan15
#Partially deleted in new
chr8	43000000	50000000	anderson13_michigan17_price17
#Partially deleted in new
chr10	37000000	43000000	anderson15_michigan19_price19
#Partially deleted in new
chr11	45000000	57000000	fellay4_michigan20_price20
#Partially deleted in new
chr12	33000000	40000000	anderson17_michigan22_price22
```

## Build 36 to Build 38 Conversion Errors

```
#Split in new
chr2	85941853	100500000	michigan2_anderson2_price2
#Partially deleted in new
chr3	89000000	97500000	michigan7_price7
#Partially deleted in new
chr5	44000000	51500000	fellay1_anderson6_michigan8_price8
#Split in new
chr6	57000000	64000000	anderson9_michigan13_price13
#Split in new
chr7	55000000	66193285	anderson11_price15_michigan15
#Split in new
chr8	43000000	50000000	anderson13_michigan17_price17
#Split in new
chr10	37000000	43000000	anderson15_michigan19_price19
#Split in new
chr11	45000000	57000000	fellay4_michigan20_price20
#Partially deleted in new
chr12	33000000	40000000	anderson17_michigan22_price22
```

Some of these regions could be recovered by allowing multiple output options. 
See the [liftover site](https://genome.ucsc.edu/cgi-bin/hgLiftOver) for more details.
