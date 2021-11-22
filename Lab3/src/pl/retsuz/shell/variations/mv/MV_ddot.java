package pl.retsuz.shell.variations.mv;

import pl.retsuz.Main;
import pl.retsuz.filesystem.Composite;
import pl.retsuz.filesystem.IComposite;
import pl.retsuz.shell.gen.ICommand;
import pl.retsuz.shell.variations.gen.CommandVariation;
import pl.retsuz.shell.variations.gen.ICommandVariation;

import javax.swing.*;
import java.awt.*;
import java.util.Arrays;
import java.util.List;

public class MV_ddot extends CommandVariation {
    public MV_ddot(ICommandVariation next, ICommand parent) {
        super(next, parent, "^\\.\\.\\/[a-zA-Z0-9.l\\/_ ]*");
    }

    @Override
    public void make(String params) {
        List<String> paramList = Arrays.asList(params.split(" "));
        Composite c= (Composite) (this.getParent().getContext().getCurrent());
        Composite d= (Composite) (this.getParent().getContext().getCurrent());
        try {
            Composite newDirectory;
            while (paramList.get(0).startsWith("../"))
            {
                c = (Composite) c.getParent();
                paramList.set(0, paramList.get(0).substring(3));
            }
            while (paramList.get(1).startsWith("../"))
            {
                d = (Composite) d.getParent();
                paramList.set(1, paramList.get(1).substring(3));
            }
            IComposite elem = c.findElementByPath(paramList.get(0));
            if (paramList.get(1).contains("/")) {
                newDirectory = (Composite) (d.findElementByPath(paramList.get(1).substring(0, paramList.get(1).lastIndexOf("/"))));
                elem.setName(paramList.get(1).substring(paramList.get(1).lastIndexOf("/") + 1));
            }
            else
            {
                newDirectory = d;
                elem.setName(paramList.get(1));
            }
            Composite.moveElement(elem.getParent(), newDirectory, elem);

        }catch(Exception e){
            System.out.println("Niepoprawny argument.");
        }
    }
}