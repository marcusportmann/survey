/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.SurveyDefinition;
import digital.survey.model.SurveyResponse;
import digital.survey.model.SurveySectionDefinition;
import guru.mmp.application.web.WebApplicationException;
import org.apache.wicket.Component;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.markup.MarkupStream;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.Response;

/**
 * The <code>SurveySectionResponseReadOnlyPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveySectionResponseReadOnlyPanel extends Panel
{
  private static final long serialVersionUID = 1000000;
  private SurveyItemResponseReadOnlyPanelGroup itemResponseReadOnlyPanelGroup;

  /**
   * Constructs a new <code>SurveySectionResponseReadOnlyPanel</code>.
   *
   * @param id                           the non-null id of this component
   * @param surveySectionDefinitionModel the model for the survey section definition
   * @param surveyResponseModel          the model for the survey response
   */
  SurveySectionResponseReadOnlyPanel(String id,
      IModel<SurveySectionDefinition> surveySectionDefinitionModel,
      IModel<SurveyResponse> surveyResponseModel)
  {
    super(id);

    setRenderBodyOnly(true);

    add(new Label("label", new PropertyModel<>(surveySectionDefinitionModel, "label")));

    add(new HeadingCollapse("headingCollapse"));

    itemResponseReadOnlyPanelGroup = new SurveyItemResponseReadOnlyPanelGroup(
        "itemResponseReadOnlyPanelGroup", new PropertyModel<>(surveySectionDefinitionModel,
        "itemDefinitions"), surveyResponseModel);

    add(itemResponseReadOnlyPanelGroup);
  }

  /**
   * The <code>HeadingCollapse</code> class.
   */
  private class HeadingCollapse extends Component
  {
    private static final long serialVersionUID = 1000000;

    /**
     * Constructs a new <code>HeadingCollapse</code>.
     *
     * @param id the non-null id of this component
     */
    public HeadingCollapse(String id)
    {
      super(id);
    }

    /**
     * Render the XML panel.getItemResponsePanelGroupId
     */
    @Override
    protected void onRender()
    {
      MarkupStream markupStream = findMarkupStream();
      Response response = getResponse();

      StringBuilder buffer = new StringBuilder();

      buffer.append("<div class=\"heading-collapse collapsed\" data-toggle=\"collapse\"");
      buffer.append(" data-parent=\"#" + getItemResponsePanelGroupId());
      buffer.append("\" href=\"#" + itemResponseReadOnlyPanelGroup.getMarkupId());
      buffer.append("\"><i class=\"fa fa-plus collapsed\"></i>");
      buffer.append("<i class=\"fa fa-minus expanded\"></i></div>");

      response.write(buffer.toString());

      markupStream.next();
    }

    private String getItemResponsePanelGroupId()
    {
      MarkupContainer parent = SurveySectionResponseReadOnlyPanel.this.getParent();

      while ((parent != null) && (!parent.getId().equals("itemResponseReadOnlyPanelGroup")))
      {
        parent = parent.getParent();
      }

      if (parent != null)
      {
        return parent.getMarkupId();
      }
      else
      {
        throw new WebApplicationException(
            "Failed to find the itemResponseReadOnlyPanelGroup component");
      }
    }
  }
}
