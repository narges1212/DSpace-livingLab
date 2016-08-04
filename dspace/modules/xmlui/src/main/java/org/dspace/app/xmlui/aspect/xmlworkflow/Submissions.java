/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.xmlworkflow;


import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.Metadatum;
import org.dspace.eperson.EPerson;
import org.dspace.xmlworkflow.WorkflowConfigurationException;
import org.dspace.xmlworkflow.WorkflowFactory;
import org.dspace.xmlworkflow.state.Step;
import org.dspace.xmlworkflow.state.Workflow;
import org.dspace.xmlworkflow.state.actions.WorkflowActionConfig;
import org.dspace.xmlworkflow.storedcomponents.ClaimedTask;
import org.dspace.xmlworkflow.storedcomponents.PoolTask;
import org.dspace.xmlworkflow.storedcomponents.XmlWorkflowItem;
import org.xml.sax.SAXException;
import org.dspace.authorize.AuthorizeManager;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.List;


/**
 * @author Bram De Schouwer (bram.deschouwer at dot com)
 * @author Kevin Van de Velde (kevin at atmire dot com)
 * @author Ben Bosman (ben at atmire dot com)
 * @author Mark Diggory (markd at atmire dot com)
 */
public class Submissions extends AbstractDSpaceTransformer
{
    /** General Language Strings */
    protected static final Message T_title =
            message("xmlui.Submission.Submissions.title");
    protected static final Message T_dspace_home =
            message("xmlui.general.dspace_home");
    protected static final Message T_trail =
            message("xmlui.Submission.Submissions.trail");
    protected static final Message T_head =
            message("xmlui.Submission.Submissions.head");
    protected static final Message T_untitled =
            message("xmlui.Submission.Submissions.untitled");
    protected static final Message T_email =
            message("xmlui.Submission.Submissions.email");

    // used by the workflow section
    protected static final Message T_w_head1 =
            message("xmlui.Submission.Submissions.workflow_head1");
    protected static final Message T_w_info1 =
            message("xmlui.Submission.Submissions.workflow_info1");
    protected static final Message T_w_head2 =
            message("xmlui.Submission.Submissions.workflow_head2");
    protected static final Message T_w_column1 =
            message("xmlui.Submission.Submissions.workflow_column1");
    protected static final Message T_w_column2 =
            message("xmlui.Submission.Submissions.workflow_column2");
    protected static final Message T_w_column3 =
            message("xmlui.Submission.Submissions.workflow_column3");
    protected static final Message T_w_column4 =
            message("xmlui.Submission.Submissions.workflow_column4");
    protected static final Message T_w_column5 =
            message("xmlui.Submission.Submissions.workflow_column5");
    protected static final Message T_w_submit_return =
            message("xmlui.Submission.Submissions.workflow_submit_return");
    protected static final Message T_w_info2 =
            message("xmlui.Submission.Submissions.workflow_info2");
    protected static final Message T_w_head3 =
            message("xmlui.Submission.Submissions.workflow_head3");
    protected static final Message T_w_submit_take =
            message("xmlui.Submission.Submissions.workflow_submit_take");
    protected static final Message T_w_info3 =
            message("xmlui.Submission.Submissions.workflow_info3");

    // Used in the in progress section
    protected static final Message T_p_head1 =
            message("xmlui.Submission.Submissions.progress_head1");
    protected static final Message T_p_info1 =
            message("xmlui.Submission.Submissions.progress_info1");
    protected static final Message T_p_column1 =
            message("xmlui.Submission.Submissions.progress_column1");
    protected static final Message T_p_column2 =
            message("xmlui.Submission.Submissions.progress_column2");
    protected static final Message T_p_column3 =
            message("xmlui.Submission.Submissions.progress_column3");
    //private static final Message T_button_delete = message("xmlui.XMLWorkflow.WorkflowOverviewTransformer.button.submit_delete");

    // Used in Search and Sort section   ...
    private static final Message T_sort_by = message("xmlui.ArtifactBrowser.ConfigurableBrowse.general.sort_by");
    private static final Message T_sort_by_Time = message("xmlui.Submission.Submissions.sort_by.Time");
    private static final Message T_sort_by_EPerson = message("xmlui.Submission.Submissions.sort_by.EPerson");
    private static final Message T_sort_by_Title = message("xmlui.Submission.Submissions.sort_by.Title");

    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, SQLException, IOException,
            AuthorizeException
    {
        pageMeta.addMetadata("title").addContent(T_title);

        pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
        pageMeta.addTrailLink(contextPath + "/submissions",T_trail);
    }


    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {
        Request request=ObjectModelHelper.getRequest(objectModel);
        //String titleTerm = request.getParameter("titleTerm");
        String sortieren = request.getParameter("Sortieren");
        if (sortieren == null){ sortieren = "timeSort";}
        Division div = body.addInteractiveDivision("submissions", contextPath+"/submissions", Division.METHOD_POST,"primary");
        div.setHead(T_head);

        // Control panel for sorting
        String[] sortOptions = {"bitte wählen ...","timeSort", "epersonSort", "titleSort", "journalSort"};
        String timeSort = "Datum";
        String epersonSort = "Person (Einreicher)";
        String titleSort = "Titel d. Publikation";
        String journalSort = "Zeitschrift / Serie";
        HashMap<String, String> queryParams = new HashMap<String, String>();

        //queryParams.put("titleTerm", titleTerm);
        queryParams.put("hidden_previous_choice", sortieren);

        //Division interactiveDiv2 = div.addInteractiveDivision("browse-controls", contextPath + "/submissions", Division.METHOD_POST, "browse controls");
        div.setHead("Sortieren");

        // Add all the query parameters as hidden fields on the form
        for (Map.Entry<String, String> param : queryParams.entrySet())
        {
            div.addHidden(param.getKey()).setValue(param.getValue());
        }
        Table sortFormWidgetTable = div.addTable("sort", 1, 3);
        Row r = sortFormWidgetTable.addRow();
        r.addCell().addContent("Sortieren: ");
        Select sortOrderSelect = r.addCell().addSelect("Sortieren");
        sortOrderSelect.addOption(true, sortOptions[0], message(sortOptions[0]));
        sortOrderSelect.addOption(sortOptions[1], message(timeSort));
        sortOrderSelect.addOption(sortOptions[2], message(epersonSort));
        sortOrderSelect.addOption(sortOptions[3], message(titleSort));
        sortOrderSelect.addOption(sortOptions[4], message(journalSort));

        r.addCell().addButton("submit").setValue("go");
        if (queryParams.containsKey("hidden_previous_choice") && queryParams.get("hidden_previous_choice")!= null){
            if (queryParams.get("hidden_previous_choice").equals("timeSort")){
                r.addCell().addContent(" sortiert nach: " + timeSort);
            }
            if (queryParams.get("hidden_previous_choice").equals("titleSort")){
                r.addCell().addContent(" sortiert nach: " + titleSort);
            }
            if (queryParams.get("hidden_previous_choice").equals("epersonSort")){
                r.addCell().addContent(" sortiert nach: " + epersonSort);
            }
            if (queryParams.get("hidden_previous_choice").equals("journalSort")){
                r.addCell().addContent(" sortiert nach: " + journalSort);
            }
        } else {
            r.addCell().addContent("");
        }

        // sortFormWidgetList.addItem().addText( "debug-output" ).setValue( request.getParameter("Sortieren") );
        // and now the tables:

        this.addWorkflowTasks(div);
//        this.addUnfinishedSubmissions(div);
        this.addSubmissionsInWorkflow(div);
//        this.addPreviousSubmissions(div);



//            findItem.addHidden("continue").setValue(knot.getId());

    }

    private void addWorkflowTasksDiv(Division division) throws SQLException, WingException, AuthorizeException, IOException {
        division.addDivision("start-submision");
    }

    /**
     * If the user has any workflow tasks, either assigned to them or in an
     * available pool of tasks, then build two tables listing each of these queues.
     *
     * If the user doesn't have any workflows then don't do anything.
     *
     * @param division The division to add the two queues too.
     */

    private void addWorkflowTasks(Division division) throws SQLException, WingException, AuthorizeException, IOException {
        Request request=ObjectModelHelper.getRequest(objectModel);
        String sortParam = request.getParameter("Sortieren");
        if (sortParam == null || sortParam.equals("bitte wählen ...")){ sortParam = "timeSort";}

        java.util.List<ClaimedTask> ownedItems;
        java.util.List<PoolTask> pooledItems;
        ownedItems = ClaimedTask.findByEperson(context, context.getCurrentUser().getID());

        pooledItems = PoolTask.findByEperson(context, context.getCurrentUser().getID());

        if (!(ownedItems.size() > 0 || pooledItems.size() > 0))
            // No tasks, so don't show the table.
            return;


        Division workflow = division.addDivision("workflow-tasks");

        workflow.setHead(T_w_head1);
        workflow.addPara(T_w_info1);
        // Tasks you own
        Table table = workflow.addTable("workflow-tasks",ownedItems.size() + 2,5);
        table.setHead(T_w_head2);

        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCellContent(T_w_column1);
        header.addCellContent(T_w_column2);
        header.addCellContent(T_w_column3);
        header.addCellContent(T_w_column4);
        header.addCellContent(T_w_column5);

        //Only show our return to pool button if we have a task that CAN be returned to a pool
        boolean showReturnToPoolButton = false;
        if (ownedItems.size() > 0)
        {
            // Put ClaimedTask object and term to sort in a map
            Map<ClaimedTask, String> m = new HashMap<ClaimedTask, String>();
            java.util.List<ClaimedTask> sorted_ownedItems;
            // Additional Iteration for sorting the Items before displaying
            for (ClaimedTask owned : ownedItems)
            {
                int workflowItemID = owned.getWorkflowItemID();
                XmlWorkflowItem item = XmlWorkflowItem.find(context, workflowItemID);

                if (sortParam.equals("titleSort")){
                    Metadatum[] titles = item.getItem().getDC("title", null, Item.ANY);
                    if (titles[0].value != null) {
                        m.put(owned, titles[0].value);
                    } else {
                        m.put(owned, "ZZZZ");
                    }
                }
                if (sortParam.equals("timeSort")){
                    Date date = item.getItem().getLastModified();
                    m.put(owned, date.toString());
                }
                if (sortParam.equals("epersonSort")){
                    EPerson submitter = item.getSubmitter();
                    String submitterEmail = submitter.getEmail();
                    m.put(owned, submitterEmail);
                }
                if (sortParam.equals("journalSort")){
                    Metadatum[] journals = null;
                    if (item.getItem().getDC("source", "journal" , Item.ANY) != null && item.getItem().getDC("source", "journal" , Item.ANY).length > 0 ) {
                        journals = item.getItem().getDC("source", "journal", Item.ANY);
                        m.put(owned, journals[0].value);
                    }
                    else if (item.getItem().getDC("source", "series" , Item.ANY) != null && item.getItem().getDC("source", "series" , Item.ANY).length > 0) {
                        journals = item.getItem().getDC("source", "series", Item.ANY);
                        m.put(owned, journals[0].value);
                    }
                    else {
                        m.put(owned, "ZZZZ");
                    }
                }
            }

            sorted_ownedItems = new ArrayList<ClaimedTask>(sortCTByValue(m).keySet());

            for (ClaimedTask owned_Items : sorted_ownedItems)
            {
                int workflowItemID = owned_Items.getWorkflowItemID();
                String stepID = owned_Items.getStepID();
                String actionID = owned_Items.getActionID();
                XmlWorkflowItem item = null;
                try {
                    item = XmlWorkflowItem.find(context, workflowItemID);
                    Workflow wf = WorkflowFactory.getWorkflow(item.getCollection());
                    Step step = wf.getStep(stepID);
                    WorkflowActionConfig action = step.getActionConfig(actionID);
                    String url = contextPath+"/handle/"+item.getCollection().getHandle()+"/xmlworkflow?workflowID="+workflowItemID+"&stepID="+stepID+"&actionID="+actionID;
                    Metadatum[] titles = item.getItem().getDC("title", null, Item.ANY);
                    String collectionName = item.getCollection().getMetadata("name");
                    EPerson submitter = item.getSubmitter();
                    String submitterName = submitter.getFullName();
                    String submitterEmail = submitter.getEmail();

                    //        		Message state = getWorkflowStateMessage(owned);

                    boolean taskHasPool = step.getUserSelectionMethod().getProcessingAction().usesTaskPool();
                    if(taskHasPool){
                        //We have a workflow item that uses a pool, ensure we see the return to pool button
                        showReturnToPoolButton = true;
                    }

                    Row row = table.addRow();

                    Cell firstCell = row.addCell();
                    if(taskHasPool){
                        CheckBox remove = firstCell.addCheckBox("workflowandstepID");
                        remove.setLabel("selected");
                        remove.addOption(workflowItemID + ":" + step.getId());

                    }

                    // The task description
                    row.addCell().addXref(url,message("xmlui.XMLWorkflow." + wf.getID() + "." + stepID + "." + actionID));

                    // The item description
                    if (titles != null && titles.length > 0)
                    {
                        String displayTitle = titles[0].value;
                        // Full title to display not only 50 letters
                        //if (displayTitle.length() > 50)
                        //    displayTitle = displayTitle.substring(0,50)+ " ...";
                        row.addCell().addXref(url,displayTitle);
                    }
                    else
                        row.addCell().addXref(url,T_untitled);

                    // Submitted too
                    row.addCell().addXref(url,collectionName);

                    // Submitted by
                    Cell cell = row.addCell();
                    cell.addContent(T_email);
                    cell.addXref("mailto:"+submitterEmail,submitterName);
                } catch (WorkflowConfigurationException e) {
                    Row row = table.addRow();
                    row.addCell().addContent("Error: Configuration error in workflow.");

                } catch (Exception e) {
                }
            }

            if(showReturnToPoolButton){
                Row row = table.addRow();
                row.addCell(0,5).addButton("submit_return_tasks").setValue(T_w_submit_return);
            }

        }
        else
        {
            Row row = table.addRow();
            row.addCell(0,5).addHighlight("italic").addContent(T_w_info2);
        }


        // Deleting items out of working list
        if(AuthorizeManager.isAdmin(context)) {
            Row row2 = table.addRow();
            row2.addCell(4, 5);
            row2.addCell().addButton("submit_delete").setValue("Löschen");
        }

        // Tasks in the pool
        table = workflow.addTable("workflow-tasks",pooledItems.size()+2,5);
        table.setHead(T_w_head3);

        header = table.addRow(Row.ROLE_HEADER);
        header.addCellContent(T_w_column1);
        header.addCellContent(T_w_column2);
        header.addCellContent(T_w_column3);
        header.addCellContent(T_w_column4);
        header.addCellContent(T_w_column5);

        if (pooledItems.size() > 0)
        {
            // Put PoolTask object and term to sort in a map
            Map<PoolTask, String> pm = new HashMap<PoolTask, String>();
            java.util.List<PoolTask> sorted_pooledItems;
            // Additional Iteration for sorting the Items before displaying
            for (PoolTask pooled : pooledItems)
            {
                int workflowItemID = pooled.getWorkflowItemID();
                XmlWorkflowItem item = XmlWorkflowItem.find(context, workflowItemID);

                if (sortParam.equals("titleSort")){
                    Metadatum[] titles = item.getItem().getDC("title", null, Item.ANY);
                    pm.put(pooled, titles[0].value);
                }
                if (sortParam.equals("timeSort")){
                    Date date = item.getItem().getLastModified();
                    pm.put(pooled, date.toString());
                }
                if (sortParam.equals("epersonSort")){
                    EPerson submitter = item.getSubmitter();
                    String submitterEmail = submitter.getEmail();
                    pm.put(pooled, submitterEmail);
                }
                if (sortParam.equals("journalSort")){
                    Metadatum[] journals = null;
                    if (item.getItem().getDC("source", "journal" , Item.ANY) != null && item.getItem().getDC("source", "journal" , Item.ANY).length > 0 ) {
                        journals = item.getItem().getDC("source", "journal", Item.ANY);
                        pm.put(pooled, journals[0].value);
                    }
                    else if (item.getItem().getDC("source", "series" , Item.ANY) != null && item.getItem().getDC("source", "series" , Item.ANY).length > 0) {
                        journals = item.getItem().getDC("source", "series", Item.ANY);
                        pm.put(pooled, journals[0].value);
                    }
                    else {
                        pm.put(pooled, "ZZZZ");
                    }
                }
            }
            sorted_pooledItems = new ArrayList<PoolTask>(sortPTByValue(pm).keySet());


            for (PoolTask pooled : sorted_pooledItems)
            {
                String stepID = pooled.getStepID();
                int workflowItemID = pooled.getWorkflowItemID();
                String actionID = pooled.getActionID();
                XmlWorkflowItem item;
                try {
                    item = XmlWorkflowItem.find(context, workflowItemID);
                    Workflow wf = WorkflowFactory.getWorkflow(item.getCollection());
                    String url = contextPath+"/handle/"+item.getCollection().getHandle()+"/xmlworkflow?workflowID="+workflowItemID+"&stepID="+stepID+"&actionID="+actionID;
                    Metadatum[] titles = item.getItem().getDC("title", null, Item.ANY);
                    String collectionName = item.getCollection().getMetadata("name");
                    EPerson submitter = item.getSubmitter();
                    String submitterName = submitter.getFullName();
                    String submitterEmail = submitter.getEmail();

                    //        		Message state = getWorkflowStateMessage(pooled);


                    Row row = table.addRow();

                    CheckBox claimTask = row.addCell().addCheckBox("workflowID");
                    claimTask.setLabel("selected");
                    claimTask.addOption(workflowItemID);

                    // The task description
//                    row.addCell().addXref(url,message("xmlui.Submission.Submissions.claimAction"));
                    row.addCell().addXref(url,message("xmlui.XMLWorkflow." + wf.getID() + "." + stepID + "." + actionID));

                    // The item description
                    if (titles != null && titles.length > 0)
                    {
                        String displayTitle = titles[0].value;
//                        if (displayTitle.length() > 50)
//                            displayTitle = displayTitle.substring(0,50)+ " ...";

                        row.addCell().addXref(url,displayTitle);
                    }
                    else
                        row.addCell().addXref(url,T_untitled);

                    // Submitted too
                    row.addCell().addXref(url,collectionName);

                    // Submitted by
                    Cell cell = row.addCell();
                    cell.addContent(T_email);
                    cell.addXref("mailto:"+submitterEmail,submitterName);
                } catch (WorkflowConfigurationException e) {
                    Row row = table.addRow();
                    row.addCell().addContent("Error: Configuration error in workflow.");
                } catch (Exception e) {
                }
            }
            Row row = table.addRow();
            row.addCell(0,5).addButton("submit_take_tasks").setValue(T_w_submit_take);
        }
        else
        {
            Row row = table.addRow();
            row.addCell(0,4).addHighlight("italic").addContent(T_w_info3);
        }
    }


    /**
     * There are two options, the user has some unfinished submissions
     * or the user does not.
     *
     * If the user does not, then we just display a simple paragraph
     * explaining that the user may submit new items to dspace.
     *
     * If the user does have unfinished submissions then a table is
     * presented listing all the unfinished submissions that this user has.
     *
     */

    private void addUnfinishedSubmissions(Division division) throws SQLException, WingException
    {
        division.addInteractiveDivision("unfinished-submisions", contextPath+"/submit", Division.METHOD_POST);

    }



    /**
     * This section lists all the submissions that this user has submitted which are currently under review.
     *
     * If the user has none, this nothing is displayed.
     */
    private void addSubmissionsInWorkflow(Division division) throws SQLException, WingException, AuthorizeException, IOException {
        XmlWorkflowItem[] inprogressItems;
        try {
            inprogressItems = XmlWorkflowItem.findByEPerson(context,context.getCurrentUser());
            // If there is nothing in progress then don't add anything.
            if (!(inprogressItems.length > 0))
                return;

            Division inprogress = division.addDivision("submissions-inprogress");
            inprogress.setHead(T_p_head1);
            inprogress.addPara(T_p_info1);


            Table table = inprogress.addTable("submissions-inprogress",inprogressItems.length+1,3);
            Row header = table.addRow(Row.ROLE_HEADER);
            header.addCellContent(T_p_column1);
            header.addCellContent(T_p_column2);
            header.addCellContent(T_p_column3);


            for (XmlWorkflowItem workflowItem : inprogressItems)
            {
                Metadatum[] titles = workflowItem.getItem().getDC("title", null, Item.ANY);
                String collectionName = workflowItem.getCollection().getMetadata("name");
                java.util.List<PoolTask> pooltasks = PoolTask.find(context,workflowItem);
                java.util.List<ClaimedTask> claimedtasks = ClaimedTask.find(context, workflowItem);

                Message state = message("xmlui.XMLWorkflow.step.unknown");
                for(PoolTask task: pooltasks){
                    Workflow wf = WorkflowFactory.getWorkflow(workflowItem.getCollection());
                    Step step = wf.getStep(task.getStepID());
                    state = message("xmlui.XMLWorkflow." + wf.getID() + "." + step.getId() + "." + task.getActionID());
                }
                for(ClaimedTask task: claimedtasks){
                    Workflow wf = WorkflowFactory.getWorkflow(workflowItem.getCollection());
                    Step step = wf.getStep(task.getStepID());
                    state = message("xmlui.XMLWorkflow." + wf.getID() + "." + step.getId() + "." + task.getActionID());
                }
                Row row = table.addRow();

                // Add the title column
                if (titles.length > 0)
                {
                    String displayTitle = titles[0].value;

                    row.addCellContent(displayTitle);
                }
                else
                    row.addCellContent(T_untitled);

                // Collection name column
                row.addCellContent(collectionName);

                // Status column
                row.addCellContent(state);
            }
        }  catch (Exception e) {
            Row row = division.addTable("table0",1,1).addRow();
            row.addCell().addContent("Error: Configuration error in workflow.");

        }


    }

    /**
     * Show the user's completed submissions.
     *
     * If the user has no completed submissions, display nothing.
     * If 'displayAll' is true, then display all user's archived submissions.
     * Otherwise, default to only displaying 50 archived submissions.
     *
     * @param division div to put archived submissions in
     */
    private void addPreviousSubmissions(Division division)
            throws SQLException,WingException
    {
        division.addDivision("completed-submissions");

    }
    static Map<PoolTask, String> sortPTByValue(Map<PoolTask, String> map) {
        List<Map.Entry<PoolTask, String>> list = new LinkedList(map.entrySet());
        Collections.sort(list, new Comparator<Map.Entry<PoolTask, String>>()
        {
            public int compare(Map.Entry<PoolTask, String> o1, Map.Entry<PoolTask, String> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });

        Map<PoolTask, String> result = new LinkedHashMap<>();
        for (Iterator it = list.iterator(); it.hasNext();) {
            Map.Entry<PoolTask, String> entry = (Map.Entry)it.next();
            result.put(entry.getKey(), entry.getValue());
        }
        return result;
    }
    static Map<ClaimedTask, String> sortCTByValue(Map<ClaimedTask, String> map) {
        List<Map.Entry<ClaimedTask, String>> list = new LinkedList(map.entrySet());
        Collections.sort(list, new Comparator<Map.Entry<ClaimedTask, String>>()
        {
            public int compare(Map.Entry<ClaimedTask, String> o1, Map.Entry<ClaimedTask, String> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });

        Map<ClaimedTask, String> result = new LinkedHashMap<>();
        for (Iterator it = list.iterator(); it.hasNext();) {
            Map.Entry<ClaimedTask, String> entry = (Map.Entry)it.next();
            result.put(entry.getKey(), entry.getValue());
        }
        return result;
    }
}
