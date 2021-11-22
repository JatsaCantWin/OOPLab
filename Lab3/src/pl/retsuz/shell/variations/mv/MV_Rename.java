package pl.retsuz.shell.variations.mv;


import pl.retsuz.filesystem.Composite;
import pl.retsuz.filesystem.IComposite;
import pl.retsuz.shell.gen.ICommand;
import pl.retsuz.shell.variations.gen.CommandVariation;
import pl.retsuz.shell.variations.gen.ICommandVariation;

import java.util.Arrays;
import java.util.List;

public class MV_Rename extends CommandVariation {
    public MV_Rename(ICommandVariation next, ICommand parent) {
        super(next,parent,"[a-zA-Z0-9.l_\\ ]*");
    }
    @Override
    public void make(String params) {
        List<String> paramList = Arrays.asList(params.split(" "));
        Composite c= (Composite) (this.getParent().getContext().getCurrent());
        try {
            IComposite elem = c.findElementByPath(paramList.get(0));
            elem.setName(paramList.get(1));
        }catch(Exception e){
            System.out.println("Niepoprawny argument.");
        }
    }
}