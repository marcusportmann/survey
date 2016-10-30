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

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyDefinition;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyDefinitionModel</code> class provides a detachable model
 * implementation for the <code>SurveyDefinition</code> model class.
 *
 * This detachable model implementation retrieves a version of a particular survey definition.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyDefinitionModel
    extends InjectableLoadableDetachableModel<SurveyDefinition>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   */
  private UUID id;

  /**
   * The version of the survey definition.
   */
  private int version;

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyDefinitionModel() {}

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   *
   * @param surveyDefinition the <code>SurveyDefinition</code> instance
   */
  public DetachableSurveyDefinitionModel(SurveyDefinition surveyDefinition)
  {
    this(surveyDefinition.getId(), surveyDefinition.getVersion());

    setObject(surveyDefinition);
  }

  /**
   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   */
  public DetachableSurveyDefinitionModel(UUID id, int version)
  {
    this.id = id;
    this.version = version;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyDefinition load()
  {
    try
    {
      return surveyService.getSurveyDefinition(id, version);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the version (%d) of the survey definition (%s)", version, id), e);
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
