package com.mirabilia.org.hzi.test;

import com.mirabilia.org.hzi.sormas.cases.AggregrateController;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class tester_ {

    private static List<String> fieldList = new ArrayList();

    public static void main(String[] args) throws SQLException, InstantiationException, IllegalAccessException, ClassNotFoundException {

         AggregrateController.SormasAggregrator("4");
       // AggregrateController.SendCasesInJsontoDHIS();
        
      
    }
}
