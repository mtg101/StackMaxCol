After getting a 16-col stack-blit to work in https://github.com/mtg101/StackPort I realized I could probably extend to 20-col using IX and IY registers -- T-count looks possible-ish...

So now I'm thinking: how far can I go? That demo had all sorts of column blanking and attr blitting to deal with. What if I just focus on monochromatic pixels... how many columns can I blit every frame?

Well - turns out getting past 18 cols is really hard. I hadn't taken into account memory contention for one thing. So even getting to 20 cols using all stackable registers is the new challenge. 
