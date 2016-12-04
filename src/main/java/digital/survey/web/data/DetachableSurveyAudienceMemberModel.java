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
import digital.survey.model.SurveyAudienceMember;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyAudienceMemberModel</code> class provides a detachable model
 * implementation for the <code>SurveyAudienceMember</code> model class.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyAudienceMemberModel
    extends InjectableLoadableDetachableModel<SurveyAudienceMember>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience member.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyAudienceMemberModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyAudienceMemberModel() {}

  /**
   * Constructs a new <code>DetachableSurveyAudienceMemberModel</code>.
   *
   * @param surveyAudienceMember the <code>SurveyAudienceMember</code> instance
   */
  public DetachableSurveyAudienceMemberModel(SurveyAudienceMember surveyAudienceMember)
  {
    this(surveyAudienceMember.getId());

    setObject(surveyAudienceMember);
  }

  /**
   * Constructs a new <code>DetachableSurveyAudienceMemberModel</code>.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the
   *           survey audience member
   */
  public DetachableSurveyAudienceMemberModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyAudienceMember load()
  {
    try
    {
      return surveyService.getSurveyAudienceMember(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey audience member (%s)", id), e);
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
