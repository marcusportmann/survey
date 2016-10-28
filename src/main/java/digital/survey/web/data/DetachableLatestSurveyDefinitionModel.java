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

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;
import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyDefinition;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyDefinitionModel</code> class provides a detachable model
 * implementation for the <code>SurveyDefinition</code> model class.
 *
 * This detachable model implementation retrieves the latest version of a particular survey
 * definition.
 *
 * @author Marcus Portmann
 */
public class DetachableLatestSurveyDefinitionModel
    extends InjectableLoadableDetachableModel<SurveyDefinition>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey definition.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableLatestSurveyDefinitionModel() {}

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   *
   * @param surveyDefinition the <code>SurveyDefinition</code> instance
   */
  public DetachableLatestSurveyDefinitionModel(SurveyDefinition surveyDefinition)
  {
    this(surveyDefinition.getId());

    setObject(surveyDefinition);
  }

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   *
   * @param id
   */
  public DetachableLatestSurveyDefinitionModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyDefinition load()
  {
    try
    {
      return surveyService.getLatestVersionForSurveyDefinition(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the latest version of the survey definition (%s)", id), e);
    }
  }

  /**
   * Invoked when the model is detached after use.
   */
  @Override
  protected void onDetach()
  {
    super.onDetach();

    setObject(null);
  }
}
