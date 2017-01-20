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
import guru.mmp.application.web.template.components.DropDownChoiceWithFeedback;
import guru.mmp.application.web.template.components.ExtensibleFormDialogImplementation;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinitionPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingsDefinitionPanel extends SurveyItemDefinitionPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionPanel</code>.
   *
   * @param id                                the non-null id of this component
   * @param surveyDefinitionModel             the model for the survey definition
   * @param surveyGroupRatingsDefinitionModel the model for the survey group ratings definition
   * @param surveyGroupDefinitionModel        the model for the survey group definition
   */
  public SurveyGroupRatingsDefinitionPanel(String id,
      IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<SurveyGroupRatingsDefinition> surveyGroupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> surveyGroupDefinitionModel)
  {
    super(id, surveyDefinitionModel, surveyGroupRatingsDefinitionModel);

    getBodyContainer().add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition",
        new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));

            // The "moveLeftLink" link
            AjaxLink moveLeftLink = new AjaxLink("moveLeftLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

                surveyDefinition.moveGroupRatingDefinitionUp(item.getModelObject());

                target.add(getBodyContainer());
              }
            };

            if (item.getIndex() == 0)
            {
              moveLeftLink.setVisible(false);
            }

            item.add(moveLeftLink);

            // The "removeLink" link
            item.add(new AjaxLink("removeLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                getDialog().show(target, new RemoveGroupRatingDialogImplementation(
                    surveyDefinitionModel, item.getModel()));
              }
            });

            // The "moveRightLink" link
            AjaxLink moveRightLink = new AjaxLink("moveRightLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

                surveyDefinition.moveGroupRatingDefinitionDown(item.getModelObject());

                target.add(getBodyContainer());
              }
            };

            if (item.getIndex() == (getList().size() - 1))
            {
              moveRightLink.setVisible(false);
            }

            item.add(moveRightLink);
          }
        });

    // The "addGroupRatingDefinitionLink" link
    getBodyContainer().add(new AjaxLink("addGroupRatingDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            getDialog().show(target, new AddGroupRatingDialogImplementation(surveyDefinitionModel,
                surveyGroupRatingsDefinitionModel));
          }
        });

    // The "groupMemberDefinition" list view
    getBodyContainer().add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition",
        new PropertyModel<>(surveyGroupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));

            // The "moveUpLink" link
            AjaxLink moveUpLink = new AjaxLink("moveUpLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

                surveyDefinition.moveGroupMemberDefinitionUp(item.getModelObject());

                target.add(getBodyContainer());
              }
            };

            if (item.getIndex() == 0)
            {
              moveUpLink.setVisible(false);
            }

            item.add(moveUpLink);

            // The "removeLink" link
            item.add(new AjaxLink("removeLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                getDialog().show(target, new RemoveGroupMemberDialogImplementation(
                    surveyDefinitionModel, item.getModel()));
              }
            });

            // The "moveDownLink" link
            AjaxLink moveDownLink = new AjaxLink("moveDownLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

                surveyDefinition.moveGroupMemberDefinitionDown(item.getModelObject());

                target.add(getBodyContainer());
              }
            };

            if (item.getIndex() == (getList().size() - 1))
            {
              moveDownLink.setVisible(false);
            }

            item.add(moveDownLink);

            // The "groupRatingType" list view
            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingType",
                new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                item.add(new Label("ratingType", groupRatingDefinition.getRatingType()
                    .description()));
              }
            });
          }
        });

    getBodyContainer().add(new AjaxLink("addGroupMemberDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            getDialog().show(target, new AddGroupMemberDialogImplementation(surveyDefinitionModel,
                surveyGroupRatingsDefinitionModel));
          }
        });
  }

  /**
   * Returns the Font Awesome CSS class for the icon for the survey item definition.
   *
   * @return the Font Awesome CSS class for the icon for the survey item definition
   */
  @Override
  protected String getIconClass()
  {
    return "fa-table";
  }

  /**
   * Returns whether the survey item definition is collapsible.
   *
   * @return <code>true</code> if the survey item definition is collapsible or <code>false</code>
   *         otherwise
   */
  @Override
  protected boolean isCollapsible()
  {
    return false;
  }

  /**
   * The <code>AddGroupMemberDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class AddGroupMemberDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
    private IModel<SurveyDefinition> surveyDefinitionModel;
    private String name;

    /**
     * Constructs a new <code>AddGroupMemberDialogImplementation</code>.
     *
     * @param surveyDefinitionModel       the model for the survey definition
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition being
     *                                    removed
     */
    public AddGroupMemberDialogImplementation(IModel<SurveyDefinition> surveyDefinitionModel,
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
    {
      super("Add Survey Group Member", "OK", "Canel");

      this.surveyDefinitionModel = surveyDefinitionModel;
      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;

      // The "name" field
      TextField nameField = new TextFieldWithFeedback<>("name", new PropertyModel<>(this, "name"));
      nameField.setRequired(true);
      add(nameField);
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

      SurveyGroupRatingsDefinition surveyGroupRatingsDefinition =
          groupRatingsDefinitionModel.getObject();

      SurveyGroupMemberDefinition groupMemberDefinition = new SurveyGroupMemberDefinition(name);

      surveyDefinition.getGroupDefinition(surveyGroupRatingsDefinition.getGroupDefinitionId())
          .addGroupMemberDefinition(groupMemberDefinition);

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }


  /**
   * The <code>AddGroupRatingDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class AddGroupRatingDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
    private IModel<SurveyDefinition> surveyDefinitionModel;
    private String name;
    private SurveyGroupRatingType groupRatingType;

    /**
     * Constructs a new <code>AddGroupRatingDialogImplementation</code>.
     *
     * @param surveyDefinitionModel       the model for the survey definition
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition being
     *                                    removed
     */
    public AddGroupRatingDialogImplementation(IModel<SurveyDefinition> surveyDefinitionModel,
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
    {
      super("Add Survey Group Rating", "OK", "Cancel");

      this.surveyDefinitionModel = surveyDefinitionModel;
      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;

      // The "name" field
      TextField nameField = new TextFieldWithFeedback<>("name", new PropertyModel<>(this, "name"));
      nameField.setRequired(true);
      add(nameField);

      SurveyGroupRatingTypeChoiceRenderer surveyGroupRatingTypeChoiceRenderer =
          new SurveyGroupRatingTypeChoiceRenderer();

      // The "groupRatingType" field
      DropDownChoice<SurveyGroupRatingType> groupRatingTypeField = new DropDownChoiceWithFeedback<>(
          "groupRatingType", new PropertyModel<>(this, "groupRatingType"), getRatingTypeOptions(),
          surveyGroupRatingTypeChoiceRenderer);
      groupRatingTypeField.setRequired(true);
      add(groupRatingTypeField);
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

      groupRatingsDefinitionModel.getObject().addGroupRatingDefinition(
          new SurveyGroupRatingDefinition(name, groupRatingType));

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}

    private List<SurveyGroupRatingType> getRatingTypeOptions()
    {
      List<SurveyGroupRatingType> ratingTypes = new ArrayList<>();

      ratingTypes.add(SurveyGroupRatingType.YES_NO_NA);
      ratingTypes.add(SurveyGroupRatingType.ONE_TO_TEN);

      return ratingTypes;
    }
  }


  /**
   * The <code>RemoveGroupMemberDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupMemberDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel;
    private IModel<SurveyDefinition> surveyDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupMemberDialogImplementation</code>.
     *
     * @param surveyDefinitionModel       the model for the survey definition
     * @param groupMemberDefinitionModel the model for the survey group member definition being
     *                                   removed
     */
    public RemoveGroupMemberDialogImplementation(IModel<SurveyDefinition> surveyDefinitionModel,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super("Remove Survey Group Member", "Yes", "No");

      this.surveyDefinitionModel = surveyDefinitionModel;
      this.groupMemberDefinitionModel = groupMemberDefinitionModel;

      /*
       * NOTE: We need to retrieve the name of the member definition here explicitly and not use
       *       a PropertyModel on the groupMemberDefinitionModel object with the "name" field
       *       because after removing the group member definition the model will no longer be
       *       valid and we will get an IndexOutOfBoundsException exception. This is as a result of
       *       the groupMemberDefinitionModel being a ListItemModel, which references an item in
       *       a list view that has been removed.
       */
      add(new Label("name", new Model<>(groupMemberDefinitionModel.getObject().getName())));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

      surveyDefinition.removeGroupMemberDefinition(groupMemberDefinitionModel.getObject().getId());

      // target.add(groupMemberDefinitionListView);

      // groupMemberDefinitionListView.removeAll();

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }


  /**
   * The <code>RemoveGroupRatingDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupRatingDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel;
    private IModel<SurveyDefinition> surveyDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupRatingDialogImplementation</code>.
     *
     * @param surveyDefinitionModel      the model for the survey definition
     * @param groupRatingDefinitionModel the model for the survey group rating definition being
     *                                   removed
     */
    public RemoveGroupRatingDialogImplementation(IModel<SurveyDefinition> surveyDefinitionModel,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super("Remove Survey Group Rating", "Yes", "No");

      this.surveyDefinitionModel = surveyDefinitionModel;
      this.groupRatingDefinitionModel = groupRatingDefinitionModel;

      /*
       * NOTE: We need to retrieve the name of the rating definition here explicitly and not use
       *       a PropertyModel on the groupRatingDefinitionModel object with the "name" field
       *       because after removing the group rating definition the model will no longer be
       *       valid and we will get an IndexOutOfBoundsException exception. This is as a result of
       *       the groupRatingDefinitionModel being a ListItemModel, which references an item in
       *       a list view that has been removed.
       */
      add(new Label("name", new Model<>(groupRatingDefinitionModel.getObject().getName())));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

      surveyDefinition.removeGroupRatingDefinition(groupRatingDefinitionModel.getObject().getId());

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }
}
