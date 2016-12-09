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
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

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

    WebMarkupContainer definitionContainer = new WebMarkupContainer("definitionContainer");
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
    removeGroupRatingDefinitionDialog = new RemoveGroupRatingDefinitionDialog(definitionContainer);
    add(removeGroupRatingDefinitionDialog);

    // The dialog used to confirm the removal of a survey group member definition
    removeGroupMemberDefinitionDialog = new RemoveGroupMemberDefinitionDialog(definitionContainer);
    add(removeGroupMemberDefinitionDialog);
  }

  /**
   * Show the remove survey group member definition dialog using Ajax.
   *
   * @param target                the AJAX request target
   * @param groupMemberDefinition the survey group member definition being removed
   */
  void showRemoveGroupMemberDefinitionDialog(AjaxRequestTarget target,
      SurveyGroupMemberDefinition groupMemberDefinition)
  {
    removeGroupMemberDefinitionDialog.show(target, groupMemberDefinition);
  }

  /**
   * Show the remove survey group rating definition dialog using Ajax.
   *
   * @param target                the AJAX request target
   * @param groupRatingDefinition the survey group rating definition being removed
   */
  void showRemoveGroupRatingDefinitionDialog(AjaxRequestTarget target,
      SurveyGroupRatingDefinition groupRatingDefinition)
  {
    removeGroupRatingDefinitionDialog.show(target, groupRatingDefinition);
  }

  /**
   * The <code>RemoveGroupMemberDefinitionDialog</code> class.
   */
  private class RemoveGroupMemberDefinitionDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveGroupMemberDefinitionDialog</code>.
     *
     * @param definitionContainer the survey definition container
     */
    RemoveGroupMemberDefinitionDialog(WebMarkupContainer definitionContainer)
    {
      super("removeGroupMemberDefinitionDialog");

      nameLabel = new Label("name", Model.of(""));

      nameLabel.setOutputMarkupId(true);
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

          surveyDefinition.removeGroupMemberDefinition(id);

          target.add(definitionContainer);

          hide(target);
        }
      };
      add(removeLink);
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target                the AJAX request target
     * @param groupMemberDefinition the survey group member definition being removed
     */
    void show(AjaxRequestTarget target, SurveyGroupMemberDefinition groupMemberDefinition)
    {
      id = groupMemberDefinition.getId();

      nameLabel.setDefaultModelObject(groupMemberDefinition.getName());

      target.add(nameLabel);

      super.show(target);
    }
  }


  /**
   * The <code>RemoveGroupRatingDefinitionDialog</code> class.
   */
  private class RemoveGroupRatingDefinitionDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveGroupRatingDefinitionDialog</code>.
     *
     * @param definitionContainer the survey definition container
     */
    RemoveGroupRatingDefinitionDialog(WebMarkupContainer definitionContainer)
    {
      super("removeGroupRatingDefinitionDialog");

      nameLabel = new Label("name", Model.of(""));

      nameLabel.setOutputMarkupId(true);
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

          surveyDefinition.removeGroupRatingDefinition(id);

          target.add(definitionContainer);

          hide(target);
        }
      };
      add(removeLink);
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target                the AJAX request target
     * @param groupRatingDefinition the survey group rating definition being removed
     */
    void show(AjaxRequestTarget target, SurveyGroupRatingDefinition groupRatingDefinition)
    {
      id = groupRatingDefinition.getId();

      nameLabel.setDefaultModelObject(groupRatingDefinition.getName());

      target.add(nameLabel);

      super.show(target);
    }
  }
}
