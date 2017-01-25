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

import digital.survey.model.SurveyGroupRatingsDefinition;
import digital.survey.model.SurveyItemDefinition;
import digital.survey.model.SurveySectionDefinition;
import digital.survey.model.SurveyTextDefinition;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <class>SurveyItemDefinitionPanelGroup</class>.
 *
 * @author Marcus Portmann
 */
public class SurveyItemDefinitionPanelGroup extends Panel
{
  /**
   * Constructs a new <code>SurveyItemDefinitionPanelGroup</code>.
   *
   * @param id                         the non-null id of this component
   * @param surveyItemDefinitionsModel the model for the survey item definitions
   */
  public SurveyItemDefinitionPanelGroup(String id,
      IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel)
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

              item.add(new SurveyGroupRatingsDefinitionPanel("itemDefinitionPanel",
                  surveyItemDefinitionsModel, new Model<>(groupRatingsDefinition)));
            }
            else if (itemDefinition instanceof SurveySectionDefinition)
            {
              SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) itemDefinition;

              item.add(new SurveySectionDefinitionPanel("itemDefinitionPanel",
                  surveyItemDefinitionsModel, new Model<>(sectionDefinition)));
            }
            else if (itemDefinition instanceof SurveyTextDefinition)
            {
              SurveyTextDefinition textDefinition = (SurveyTextDefinition) itemDefinition;

              item.add(new SurveyTextDefinitionPanel("itemDefinitionPanel",
                  surveyItemDefinitionsModel, new Model<>(textDefinition)));
            }
          }
        });
  }
}
