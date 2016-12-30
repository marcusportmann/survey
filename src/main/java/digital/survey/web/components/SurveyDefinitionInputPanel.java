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
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
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
  private RemoveGroupRatingDefinitionDialog removeGroupRatingDefinitionDialog;
  private RemoveGroupMemberDefinitionDialog removeGroupMemberDefinitionDialog;
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

    // The dialog used to confirm the removal of a survey group rating definition
    removeGroupRatingDefinitionDialog = new RemoveGroupRatingDefinitionDialog();
    add(removeGroupRatingDefinitionDialog);

    // The dialog used to confirm the removal of a survey group member definition
    removeGroupMemberDefinitionDialog = new RemoveGroupMemberDefinitionDialog();
    add(removeGroupMemberDefinitionDialog);
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
   * Show the remove survey group member definition dialog using Ajax.
   *
   * @param target                     the AJAX request target
   * @param groupMemberDefinitionModel the model for the survey group member definition being
   *                                   removed
   */
  void showRemoveGroupMemberDefinitionDialog(AjaxRequestTarget target,
      IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
  {
    removeGroupMemberDefinitionDialog.show(target, groupMemberDefinitionModel);
  }

  /**
   * Show the remove survey group rating definition dialog using Ajax.
   *
   * @param target                     the AJAX request target
   * @param groupRatingDefinitionModel the model for the survey group rating definition being
   *                                   removed
   */
  void showRemoveGroupRatingDefinitionDialog(AjaxRequestTarget target,
      IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
  {
    removeGroupRatingDefinitionDialog.show(target, groupRatingDefinitionModel);
  }

  /**
   * The <code>RemoveGroupMemberDefinitionDialog</code> class.
   */
  private class RemoveGroupMemberDefinitionDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveGroupMemberDefinitionDialog</code>.
     */
    RemoveGroupMemberDefinitionDialog()
    {
      super("removeGroupMemberDefinitionDialog");

      setOutputMarkupId(true);

      nameLabel = new Label("name", Model.of(""));

      add(nameLabel);

      // The "removeLink" link
      AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick(AjaxRequestTarget target)
        {
          SurveyDefinition surveyDefinition = (SurveyDefinition) SurveyDefinitionInputPanel
              .this.getDefaultModelObject();

          surveyDefinition.removeGroupMemberDefinition(groupMemberDefinitionModel.getObject()
              .getId());

          SurveyDefinitionInputPanel.this.refreshDefinitionContainer(target);

          hide(target);
        }
      };
      add(removeLink);
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target                     the AJAX request target
     * @param groupMemberDefinitionModel the model for the survey group member definition being
     *                                   removed
     */
    void show(AjaxRequestTarget target,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      this.groupMemberDefinitionModel = groupMemberDefinitionModel;

      nameLabel.setDefaultModel(new PropertyModel<>(groupMemberDefinitionModel, "name"));

      target.add(this);

      super.show(target);
    }
  }


  /**
   * The <code>RemoveGroupRatingDefinitionDialog</code> class.
   */
  private class RemoveGroupRatingDefinitionDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveGroupRatingDefinitionDialog</code>.
     */
    RemoveGroupRatingDefinitionDialog()
    {
      super("removeGroupRatingDefinitionDialog");

      setOutputMarkupId(true);

      nameLabel = new Label("name", Model.of(""));
      add(nameLabel);

      // The "removeLink" link
      AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick(AjaxRequestTarget target)
        {
          SurveyDefinition surveyDefinition = (SurveyDefinition) SurveyDefinitionInputPanel
              .this.getDefaultModelObject();

          surveyDefinition.removeGroupRatingDefinition(groupRatingDefinitionModel.getObject()
              .getId());

          SurveyDefinitionInputPanel.this.refreshDefinitionContainer(target);

          hide(target);
        }
      };
      add(removeLink);
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target                     the AJAX request target
     * @param groupRatingDefinitionModel the model for the survey group rating definition being
     *                                   removed
     */
    void show(AjaxRequestTarget target,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      this.groupRatingDefinitionModel = groupRatingDefinitionModel;

      nameLabel.setDefaultModel(new PropertyModel<>(groupRatingDefinitionModel, "name"));

      target.add(this);

      super.show(target);
    }
  }
}
