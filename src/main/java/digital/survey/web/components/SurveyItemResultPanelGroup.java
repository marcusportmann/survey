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

import digital.survey.model.*;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <class>SurveyItemResultPanelGroup</class>.
 *
 * @author Marcus Portmann
 */
public class SurveyItemResultPanelGroup extends Panel
{
  /**
   * Constructs a new <code>SurveyItemResultPanelGroup</code>.
   *
   * @param id                         the non-null id of this component
   * @param surveyDefinitionModel      the model for the survey definition
   * @param surveyItemDefinitionsModel the model for the survey item definitions
   * @param surveyResultModel          the model for the survey result
   */
  public SurveyItemResultPanelGroup(String id, IModel<SurveyDefinition> surveyDefinitionModel,
    IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel,
    IModel<SurveyResult> surveyResultModel)
  {
    super(id);

    setOutputMarkupId(true);

    add(new ListView<SurveyItemDefinition>("itemDefinition", surveyItemDefinitionsModel)
    {
      @Override
      protected void populateItem(ListItem<SurveyItemDefinition> item)
      {
        item.setRenderBodyOnly(true);

        SurveyItemDefinition itemDefinition = item.getModelObject();

        if (itemDefinition instanceof SurveyGroupRatingsDefinition)
        {
          SurveyGroupRatingsDefinition groupRatingsDefinition =
            (SurveyGroupRatingsDefinition) itemDefinition;

          item.add(new SurveyGroupRatingsResultPanel("itemResultPanel", new Model<>(
            groupRatingsDefinition), new Model<>(surveyDefinitionModel.getObject()
            .getGroupDefinition(groupRatingsDefinition.getGroupDefinitionId())),
            surveyResultModel));
        }
        else if (itemDefinition instanceof SurveySectionDefinition)
        {
          SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) itemDefinition;

          item.add(new SurveySectionResultPanel("itemResultPanel", surveyDefinitionModel,
            new Model<>(sectionDefinition), surveyResultModel));
        }
        else if (itemDefinition instanceof SurveyTextDefinition)
        {
          SurveyTextDefinition textDefinition = (SurveyTextDefinition) itemDefinition;

          item.add(new SurveyTextResultPanel("itemResultPanel", new Model<>(
            textDefinition), surveyResultModel));
        }
      }
    });
  }
}
