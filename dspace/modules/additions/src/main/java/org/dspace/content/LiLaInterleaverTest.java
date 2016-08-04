//Add DSpace licensing here at the top!
/*
package org.dspace.content;
 
import java.sql.SQLException;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.dspace.core.Context;
import org.junit.*;

import com.google.common.collect.ImmutableMap;

import static org.junit.Assert.* ;
import static org.hamcrest.CoreMatchers.*;
import org.apache.log4j.Logger;
import org.dspace.core.Constants;
 

public class LiLaInterleaverTest 
{

    private static final Logger log = Logger.getLogger(LiLaInterleaverTest.class);
 
    
    @Test
	  public void testInterleavedResult() throws Exception {
		 List<String> a1 = new LinkedList<String>(Arrays.asList("a", "b", "c", "g", "h")); // A: abcde
		 List<String> b1 = new LinkedList<String>(Arrays.asList("d", "e", "f", "g", "h")); // B: abcfg
		 
		 List<String> a = new LinkedList<String>(Arrays.asList("a", "b", "c", "d", "e")); // A: abcde
		 List<String> b = new LinkedList<String>(Arrays.asList("a", "b", "c", "f", "g")); // B: abcfg
		 
		 // I: abcdfeg
		 // T: ---ABAB
		 ImmutableMap<String, List<String>> expect = ImmutableMap.of("result", Arrays.asList("a", "b", "c","d", "f", "e","g"), "teamA", Arrays.asList("d", "e"), "teamB", Arrays.asList("f", "g"));
		 // ImmutableMap<String, List<String>> expect2 = ImmutableMap.of("result", Arrays.asList("a", "b", "c", "d", "e"), "teamA", Arrays.asList("g", "f"), "teamB", Arrays.asList("a", "b", "c", "d", "e"));
		 
		 // Map<String, List<String>> resultmy = LiLaInterleaver.getInterleavedResult(a, b, "test");
	    
		 /*
		 assertTrue("Expected similar result"+
		             "\n  'is'        = "+resultmy.get("result")+
		             "\n  'expected' = "+expect.get("result")+
		             "\n  'are in TeamA' = "+resultmy.get("teamA")+
		             "\n  'are in TeamB' = "+resultmy.get("teamB"),
		             expect.get("result").equals(resultmy.get("result")));
		 */
		 // abcfdeg
		 // abcdfeg //Anne
		 // abcfdge
		 // abcdfge
		 /*
		 assertTrue("Expected similar result"+
	             "\n  'is'        = "+resultmy.get("result")+
	             "\n  'expected' = "+expect.get("result"), 
	             this.either(expect.get("result1"), expect.get("result")));
	             */
	/*  }



}*/