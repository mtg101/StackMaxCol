After getting a 16-col stack-blit to work in https://github.com/mtg101/StackPort I realized I could probably extend to 20-col using IX and IY registers -- T-count looks possible-ish...

So now I'm thinking: how far can I go? That demo had all sorts of column blanking and attr blitting to deal with. What if I just focus on monochromatic pixels... how many columns can I blit every frame?

Well - 24 cols. YATA! \o/ But not IX/IY -- just more of the faster regs :)

Could I squeeze out another 2? Not right now.
And is it useful? No. It's 8k for the 24col. 

So I'm off to do interesting things with 16col stacks!
