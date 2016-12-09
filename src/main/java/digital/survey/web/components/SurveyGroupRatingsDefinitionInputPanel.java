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
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyGroupRatingsDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionInputPanel</code>.
   *
   * @param id                          the non-null id of this component
   * @param groupRatingsDefinitionModel the model for the survey group ratings definition
   * @param groupDefinitionModel        the model for the survey group definition
   */
  SurveyGroupRatingsDefinitionInputPanel(String id,
      IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> groupDefinitionModel)
  {
    super(id);

    add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition", new PropertyModel<>(
        groupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel = item.getModel();

            List<SurveyGroupRatingDefinition> groupRatingDefinitions = getList();

            int index = groupRatingDefinitions.indexOf(groupRatingDefinitionModel.getObject());

            item.add(new Label("name", new PropertyModel(groupRatingDefinitionModel, "name")));

            ShiftGroupRatingDefinitionLeftLink shiftLeftLink =
                new ShiftGroupRatingDefinitionLeftLink("shiftLeftLink", groupRatingDefinitionModel);

            if (index == 0)
            {
              shiftLeftLink.setVisible(false);
            }

            item.add(shiftLeftLink);

            item.add(new RemoveGroupRatingDefinitionLink("removeLink", groupRatingDefinitionModel));

            ShiftGroupRatingDefinitionRightLink shiftRightLink =
                new ShiftGroupRatingDefinitionRightLink("shiftRightLink",
                groupRatingDefinitionModel);

            if (index == (groupRatingDefinitions.size() - 1))
            {
              shiftRightLink.setVisible(false);
            }

            item.add(shiftRightLink);
          }
        });

    add(new AjaxLink("addGroupRatingDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            System.out.println("[DEBUG] add survey group rating definition link clicked");

          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition", new PropertyModel<>(
        groupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel = item.getModel();

            List<SurveyGroupMemberDefinition> groupMemberDefinitions = getList();

            int index = groupMemberDefinitions.indexOf(groupMemberDefinitionModel.getObject());

            item.add(new Label("name", new PropertyModel(groupMemberDefinitionModel, "name")));

            ShiftGroupMemberDefinitionUpLink shiftUpLink = new ShiftGroupMemberDefinitionUpLink(
                "shiftUpLink", groupMemberDefinitionModel);

            if (index == 0)
            {
              shiftUpLink.setVisible(false);
            }

            item.add(shiftUpLink);

            item.add(new RemoveGroupMemberDefinitionLink("removeLink", groupMemberDefinitionModel));

            ShiftGroupMemberDefinitionDownLink shiftDownLink =
                new ShiftGroupMemberDefinitionDownLink("shiftDownLink", item.getModel());

            if (index == (groupMemberDefinitions.size() - 1))
            {
              shiftDownLink.setVisible(false);
            }

            item.add(shiftDownLink);

            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingType",
                new PropertyModel<>(groupRatingsDefinitionModel, "groupRatingDefinitions"))
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

    add(new AjaxLink("addGroupMemberDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            System.out.println("[DEBUG] add survey group member definition link clicked");

          }
        });
  }

  private SurveyDefinitionInputPanel getSurveyDefinitionInputPanel()
  {
    MarkupContainer parent = getParent();

    while (parent != null)
    {
      if (parent instanceof SurveyDefinitionInputPanel)
      {
        return (SurveyDefinitionInputPanel) parent;
      }

      parent = parent.getParent();
    }

    return null;
  }

  class RemoveGroupMemberDefinitionLink extends AjaxLink<SurveyGroupMemberDefinition>
  {
    /**
     * Constructs a new <code>RemoveGroupMemberDefinitionLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupMemberDefinitionModel the model for the survey group member definition this link
     *                                   is associated with
     */
    RemoveGroupMemberDefinitionLink(String id,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super(id, groupMemberDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target)
    {
      getSurveyDefinitionInputPanel().showRemoveGroupMemberDefinitionDialog(target, getModel());
    }
  }


  /**
   * The <code>RemoveGroupRatingDefinitionLink</code> class.
   */
  class RemoveGroupRatingDefinitionLink extends AjaxLink<SurveyGroupRatingDefinition>
  {
    /**
     * Constructs a new <code>RemoveGroupRatingDefinitionLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupRatingDefinitionModel the model for the survey group rating definition this link
     *                                   is associated with
     */
    RemoveGroupRatingDefinitionLink(String id,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super(id, groupRatingDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target)
    {
      getSurveyDefinitionInputPanel().showRemoveGroupRatingDefinitionDialog(target, getModel());
    }
  }


  /**
   * The <code>ShiftGroupMemberDefinitionDownLink</code> class.
   */
  class ShiftGroupMemberDefinitionDownLink extends AjaxLink<SurveyGroupMemberDefinition>
  {
    /**
     * Constructs a new <code>ShiftGroupMemberDefinitionDownLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupMemberDefinitionModel the model for the survey group member definition this link
     *                                   is associated with
     */
    ShiftGroupMemberDefinitionDownLink(String id,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super(id, groupMemberDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target)
    {
      SurveyDefinitionInputPanel surveyDefinitionInputPanel = getSurveyDefinitionInputPanel();

      SurveyDefinition surveyDefinition =
          (SurveyDefinition) surveyDefinitionInputPanel.getDefaultModelObject();

      // surveyDefinition.shiftGroupMemberDefinitionDown(getModel().getObject());

      surveyDefinitionInputPanel.refreshDefinitionContainer(target);
    }
  }


  /**
   * The <code>ShiftGroupMemberDefinitionUpLink</code> class.
   */
  class ShiftGroupMemberDefinitionUpLink extends AjaxLink<SurveyGroupMemberDefinition>
  {
    /**
     * Constructs a new <code>ShiftGroupMemberDefinitionUpLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupMemberDefinitionModel the model for the survey group member definition this link
     *                                   is associated with
     */
    ShiftGroupMemberDefinitionUpLink(String id,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super(id, groupMemberDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target) {}
  }


  /**
   * The <code>ShiftGroupRatingDefinitionLeftLink</code> class.
   */
  class ShiftGroupRatingDefinitionLeftLink extends AjaxLink<SurveyGroupRatingDefinition>
  {
    /**
     * Constructs a new <code>ShiftGroupRatingDefinitionLeftLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupRatingDefinitionModel the model for the survey group rating definition this link
     *                                   is associated with
     */
    ShiftGroupRatingDefinitionLeftLink(String id,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super(id, groupRatingDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target) {}
  }


  /**
   * The <code>ShiftGroupRatingDefinitionRightLink</code> class.
   */
  class ShiftGroupRatingDefinitionRightLink extends AjaxLink<SurveyGroupRatingDefinition>
  {
    /**
     * Constructs a new <code>ShiftGroupRatingDefinitionRightLink</code>.
     *
     * @param id                         the non-null id of this component
     * @param groupRatingDefinitionModel the model for the survey group rating definition this link
     *                                   is associated with
     */
    ShiftGroupRatingDefinitionRightLink(String id,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super(id, groupRatingDefinitionModel);
    }

    @Override
    public void onClick(AjaxRequestTarget target) {}
  }
}
