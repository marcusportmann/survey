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
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.FormDialog;
import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveyDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;
  private WebMarkupContainer definitionContainer;

  /**
   * Constructs a new <code>SurveyDefinitionInputPanel</code>.
   *
   * @param id                    the non-null id of this component
   * @param surveyDefinitionModel the model for the survey response
   */
  public SurveyDefinitionInputPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel)
  {
    super(id, surveyDefinitionModel);

    setOutputMarkupId(true);

    // The "name" field
    TextField<String> nameField = new TextFieldWithFeedback<>("name");
    nameField.setRequired(true);
    add(nameField);

    // The "description" field
    TextField<String> descriptionField = new TextFieldWithFeedback<>("description");
    descriptionField.setRequired(true);
    add(descriptionField);

    definitionContainer = new WebMarkupContainer("definitionContainer");
    definitionContainer.setOutputMarkupId(true);
    add(definitionContainer);

    definitionContainer.add(new ListView<SurveyItemDefinition>("itemDefinition",
        new PropertyModel<>(surveyDefinitionModel, "itemDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyItemDefinition> item)
          {
            SurveyItemDefinition itemDefinition = item.getModelObject();

            if (itemDefinition instanceof SurveyGroupRatingsDefinition)
            {
              SurveyGroupRatingsDefinition groupRatingsDefinition =
                  (SurveyGroupRatingsDefinition) itemDefinition;

              item.add(new SurveyGroupRatingsDefinitionInputPanel("itemDefinitionPanel",
                  new Model<>(groupRatingsDefinition), new Model<>(surveyDefinitionModel.getObject()
                  .getGroupDefinition(groupRatingsDefinition.getGroupDefinitionId()))));
            }
          }
        });
  }

  /**
   * Refresh the definition container.
   *
   * @param target the AJAX request target
   */
  void refreshDefinitionContainer(AjaxRequestTarget target)
  {
    target.add(definitionContainer);
  }


  /**
   * Show the remove survey group rating definition dialog using Ajax.
   *
   * @param target                     the AJAX request target
   * @param groupRatingDefinitionModel the model for the survey group rating definition being
   *                                   removed
   * @param itemDefinitionInputPanelId the markup ID of the item definition input panel the
   *                                   survey group rating definition is associated with
   */
  void showRemoveGroupRatingDefinitionDialog(AjaxRequestTarget target,
      IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel,
      String itemDefinitionInputPanelId)
  {
  }


}
