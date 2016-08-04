package org.dspace.app.xmlui.aspect.discovery;

import java.util.List;

import org.dspace.content.DSpaceObject;

/**
 *
 * @author Narges Tavakolpoursaleh
 */
public interface LiLaSearchListener {
      void livinglabLog(String srt, DSpaceObject scope, String sort,int cpage, int ppage, String order, List<String> rankers);
}
