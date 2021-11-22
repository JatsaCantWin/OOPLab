package pl.retsuz.shell.variations.mkdir;

import pl.retsuz.filesystem.Composite;
import pl.retsuz.filesystem.IComposite;
import pl.retsuz.shell.gen.ICommand;
import pl.retsuz.shell.variations.gen.CommandVariation;
import pl.retsuz.shell.variations.gen.ICommandVariation;

public class MKDIR_ddot extends CommandVariation {
    public MKDIR_ddot(ICommandVariation next, ICommand parent) {
        super(next, parent, "^\\.\\.");
    }

    @Override
    public void make(String params) {

        Composite c= (Composite) (this.getParent().getContext().getCurrent());
        try {
            while (params.startsWith("../"))
            {
                c = (Composite) c.getParent();
                params = params.substring(3);
            }
            IComposite elem;
            String name;
            if (!params.contains("/"))
            {
                elem = c;
                name = params;
            }
            else
            {
                name = params.substring(params.lastIndexOf("/")+1);
                params = params.substring(0, params.lastIndexOf("/"));
                elem = c.findElementByPath(params);
            }
            Composite newElem = new Composite();
            newElem.setName(name);
            ((Composite) elem).addElement(newElem);

            System.out.println("Element zostal dodany.");
        } catch (Exception e){
            System.out.println("Nieprawidlowy argument");
        }
    }
}