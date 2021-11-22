package pl.retsuz.shell.variations.rm;

import pl.retsuz.filesystem.Composite;
import pl.retsuz.filesystem.IComposite;
import pl.retsuz.shell.gen.ICommand;
import pl.retsuz.shell.variations.gen.CommandVariation;
import pl.retsuz.shell.variations.gen.ICommandVariation;

import java.util.ArrayList;
import java.util.List;

public class RM_ddot extends CommandVariation {
    public RM_ddot(ICommandVariation next, ICommand parent) {
        super(next, parent, "^^\\.\\.\\/[a-zA-Z0-9.l\\/_]*");
    }

    @Override
    public void make(String params) {
        IComposite c= (this.getParent().getContext().getCurrent());
        List<IComposite> ParentList = new ArrayList<>();
        try {
            while (params.startsWith("../"))
            {
                ParentList.add(c);
                c = c.getParent();
                params = params.substring(3);
            }
            IComposite elem = ((Composite) c).findElementByPath(params);
            if ((elem instanceof Composite) && (ParentList.contains(elem))){
                System.out.println("Usuwanie elementow nadrzednych jest niedozwolone");
                return;
            }
            ((Composite) elem.getParent()).removeElement(elem);
            System.out.println("Element zostal usuniety.");
        } catch (Exception e){
            System.out.println("Taki element nie istnieje.");
        }
    }
}