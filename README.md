# Near Death Experience Themes Analysis

TidyTuesday project (week of July 21, 2026) exploring themes in near death experience narratives, using data from the NDERF archive.

## Question

Which themes appear most often in reported near death experiences, and do they differ by gender?

## Data

589 experiences from the NDERF archive, sourced via the TidyTuesday project. Each story is tagged with eight AI detected themes, including out of body experiences, feelings of unity, hellish elements, clinical death details, extrasensory perception, past life memories, visions of the future, and alien encounters.

## Method

Reshaped the eight theme columns into long format using pivot_longer, then calculated the share of stories reporting each theme, overall and split by gender.

## Findings

Clinical death detail (89.5%) and out of body experiences (57.2%) dominate nearly every account, forming the baseline of what a near death experience typically includes. Less common themes drop off sharply: unity (16.3%), extrasensory perception (15.3%), hellish elements (7.8%).

Gender differences were mostly small, with two exceptions. Visions of the world's future were roughly twice as common among men (6.4%) as women (3.2%), and alien encounters were reported only by men (2% vs 0%).

## Caveat

Self reported, unverified accounts submitted to a single archive, not a representative sample of near death experiences generally.

## Files

- `analysis.R`: full analysis code
- `theme_overall.png`: overall theme frequency chart
- `theme_by_gender.png`: theme frequency split by gender

